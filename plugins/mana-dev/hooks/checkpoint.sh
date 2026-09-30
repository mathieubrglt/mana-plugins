#!/bin/sh
# The Stop hook of the Mana plugin: the storing checkpoint (plugin slice C2,
# 2026-09-30).
#
# Before the agent stops after a stretch of work, it asks the agent once to
# store in Mana what the work produced. It holds the stop, and the agent
# continues once, only when all of these are true:
#   - stop_hook_active is not true, so it never holds a stop that it caused;
#   - the person wrote at least MIN_PROMPTS prompts since the last checkpoint
#     of this session, or since the session started;
#   - this session had fewer than MAX_CHECKPOINTS checkpoints.
# It keeps, for each session_id, one line "<prompts> <checkpoints>": the
# prompt count at the last checkpoint and the number of checkpoints, in
# CLAUDE_PLUGIN_DATA, or in TMPDIR when that is unset.
#
# The stretch is measured in prompts of the person, not in transcript lines.
# Claude Code 2.1.281 writes tens of bookkeeping lines for each turn, so a
# line count grew past any small bound at almost every stop (the review of
# C2, 2026-09-30). The storing turn that a checkpoint causes adds no prompt:
# Claude Code records the checkpoint as a hook_additional_context
# attachment, not as a user line.
#
# It reads the transcript on this machine only to count the person's
# prompts. It prints nothing from the transcript, and it sends nothing
# anywhere. Its only output is the checkpoint itself.
#
# The checkpoint is hookSpecificOutput.additionalContext, not the top-level
# decision "block" with a reason. A real run of Claude Code 2.1.281 (C2,
# 2026-09-30) honoured both: the agent continued once, and the next stop
# carried stop_hook_active true. The top-level form records a
# hook_blocking_error and shows the person "Stop hook error occurred"; the
# additionalContext form records a hook_success and shows no error.
#
# It fails open: on any error it exits 0 with no output, and the stop goes
# through, because a broken hook must never stop a person's work. A state
# line that is not two plain numbers is such an error: the hook leaves it as
# it is and asks nothing in that session.
#
# POSIX sh with grep, sed and wc only: no Node, no Python, no jq.
#
# REASON is CHECKPOINT_REASON in src/mcp/connect-prompt.ts, word for word;
# tests/plugin.test.ts holds the two equal.

exec 2>/dev/null

MIN_PROMPTS=10
MAX_CHECKPOINTS=2
REASON='Mana checkpoint: before you stop, store in Mana each decision, learning, or idea from this organization’s work that is not stored yet, with the Mana tool whose name ends with mana_remember_interaction. When there is nothing to store, answer: nothing to store.'

input=$(sed -n p) || exit 0

# Never hold a stop that this hook caused.
if printf '%s\n' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

# The session id names the state file, so it must be a plain name.
session=$(printf '%s\n' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9_-]*\)".*/\1/p')
case $session in
  '' | *[!A-Za-z0-9_-]*) exit 0 ;;
esac

# A path with a JSON escape in it is refused, not decoded.
transcript=$(printf '%s\n' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"\\]*\)".*/\1/p')
case $transcript in
  '' | *'
'*) exit 0 ;;
esac
[ -f "$transcript" ] && [ -r "$transcript" ] || exit 0

# A prompt of the person is a user line that is not a tool result, a meta
# line, a local command, or a notice from the harness.
prompts=$(grep '"type":"user"' "$transcript" \
  | grep -v -e '"tool_result"' -e '"isMeta":true' -e '"isSidechain":true' \
      -e '<command-name>' -e '<local-command' -e '<task-notification>' \
  | wc -l | sed 's/[^0-9]//g')
case $prompts in
  '' | *[!0-9]*) exit 0 ;;
esac
[ "$prompts" -ge "$MIN_PROMPTS" ] || exit 0

if [ -n "$CLAUDE_PLUGIN_DATA" ]; then
  dir=$CLAUDE_PLUGIN_DATA
else
  dir=$TMPDIR
fi
[ -n "$dir" ] && [ -d "$dir" ] || exit 0
state="${dir%/}/mana-checkpoint-$session"
[ -L "$state" ] && exit 0

last=0
asked=0
if [ -e "$state" ]; then
  [ -f "$state" ] || exit 0
  line=$(sed -n 1p "$state")
  case $line in
    *' '*' '* | *' ') exit 0 ;;
    ?*' '?*) ;;
    *) exit 0 ;;
  esac
  last=${line%% *}
  asked=${line#* }
  # Each part is a plain decimal number: digits only, and no leading zero,
  # because sh arithmetic reads 09 as a bad octal number.
  for part in "$last" "$asked"; do
    case $part in
      '' | *[!0-9]* | 0?*) exit 0 ;;
    esac
  done
fi
[ "$asked" -lt "$MAX_CHECKPOINTS" ] || exit 0
# A transcript with fewer prompts than the state is a new transcript.
[ "$last" -le "$prompts" ] || last=0
[ $((prompts - last)) -ge "$MIN_PROMPTS" ] || exit 0

# Ask only when the new state is kept, so that a state that cannot be
# written never asks at every stop.
printf '%s %s\n' "$prompts" $((asked + 1)) > "$state" || exit 0
printf '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"%s"}}\n' "$REASON"
exit 0
