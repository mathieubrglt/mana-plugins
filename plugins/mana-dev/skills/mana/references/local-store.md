# A local Mana store

This applies only when Mana runs from a local install instead of the hosted
service: the store is a directory on this machine and the CLI reaches it.

## Home

`MANA_HOME` is the directory that holds the Mana source and its
`mana-state/`. CLI calls run as
`npm --prefix <MANA_HOME> run mana -- <command> --state <MANA_HOME>/mana-state …`.

## The CLI when the MCP tools are absent

- Answer: `search --query '<question>'` for discovery, `retrieve --query
  '<question>'` for one evidence pack. Answer only from returned evidence.
- Remember: `remember-interaction --interaction-id <id> --type <type>
  --memory-key <key> --file <statement file> [--reason <text>]`. Write a
  multi-line statement to the file first; `--text` carries one line.
- Review: `memory queue` lists the records one review can clear, each with
  the action that clears it.

## Sync a vault or a directory

1. Register the directory once: `source add-local --root <path>`. It prints
   the connection id; registering the same root again returns the same id.
2. Read the plan first: `sync-local --connection <id> --dry-run`. It says
   what would be captured, what is unchanged, what went missing, and names
   every skipped file with its reason.
3. Import: `sync-local --connection <id>`, with `--limit <n>` to stop after
   n notes; the next run continues where it stopped.
4. Report captured, unchanged, missing, skipped and quarantined. When
   quarantined rose, run `quarantine list` and name the notes that stayed
   out (a note holding a credential stays out until it is edited).

## Autosync

`scripts/autosync.sh <15m|1h|4h|off> <MANA_HOME> <connection id>` keeps one
crontab line marked `# mana-autosync` and leaves every other line alone.
Tell the person the active cadence; `sync.log` in `MANA_HOME` holds the
outcomes. A run that finds the store held by an open session fails, and the
next run catches up.

## When calls fail

1. "Already open in another process": another session holds the store.
   Wait and retry once; do not force anything.
2. A stale server: `ps aux | grep "mcp --state"`; when one exists and no
   other session uses Mana, stop that process.
3. A derived-state error: `index rebuild`, then `context rebuild`. Derived
   data rebuilds from canonical data; the knowledge is safe.
4. Never delete `MANA_HOME` or `mana-state/`: deleting knowledge is the
   person's own act.
