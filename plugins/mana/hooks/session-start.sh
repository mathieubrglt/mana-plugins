#!/bin/sh
# The SessionStart hook of the Mana plugin (plugin slice C2, 2026-09-30).
#
# It prints the Mana rules as session context, on startup, resume, clear and
# compact. The rules are PLUGIN_RULES in src/mcp/connect-prompt.ts, which
# scripts/publish-plugin.mjs writes into rules.md beside this script. It
# makes no network call.
#
# It fails open: when the rules file is absent or cannot be read, it prints
# nothing and exits 0, and the session starts as usual.

exec 2>/dev/null

case $0 in
  */*) here=${0%/*} ;;
  *) here=. ;;
esac
rules="$here/rules.md"

[ -f "$rules" ] && [ -r "$rules" ] || exit 0
sed -n p "$rules"
exit 0
