#!/bin/sh
# Keep one crontab line that syncs a local Mana source on a cadence.
#   autosync.sh <15m|1h|4h|off> <MANA_HOME> <connection id>
# The line carries the marker `# mana-autosync`; every other line is kept.
set -eu

cadence="${1:-}"
home="${2:-}"
connection="${3:-}"
marker='# mana-autosync'

case "$cadence" in
  15m) schedule='*/15 * * * *' ;;
  1h) schedule='0 * * * *' ;;
  4h) schedule='0 */4 * * *' ;;
  off) schedule='' ;;
  *) echo "usage: autosync.sh <15m|1h|4h|off> <MANA_HOME> <connection id>" >&2; exit 2 ;;
esac

current="$(crontab -l 2>/dev/null | grep -v "$marker" || true)"
if [ -z "$schedule" ]; then
  printf '%s\n' "$current" | sed '/^$/d' | crontab -
  echo "autosync is off"
  exit 0
fi

case "$connection" in
  src_local_*) ;;
  *) echo "the connection id must be a local source id (src_local_...)" >&2; exit 2 ;;
esac
[ -d "$home/mana-state" ] || { echo "no mana-state directory under $home" >&2; exit 2; }
npm_path="$(command -v npm)"
line="$schedule $npm_path --prefix $home run mana -- sync-local --state $home/mana-state --connection $connection >> $home/sync.log 2>&1 $marker"
printf '%s\n%s\n' "$current" "$line" | sed '/^$/d' | crontab -
echo "autosync every $cadence"
