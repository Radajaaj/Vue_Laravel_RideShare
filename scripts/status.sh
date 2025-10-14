#!/usr/bin/env bash
set -euo pipefail

BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
RUN_DIR="$BASEDIR/run"
LOG_DIR="$BASEDIR/logs"

printf "%-12s %-8s %s\n" "SERVICE" "PID" "STATUS"
if [ -d "$RUN_DIR" ]; then
  for f in "$RUN_DIR"/*.pid; do
    [ -e "$f" ] || continue
    name=$(basename "$f" .pid)
    pid=$(cat "$f" 2>/dev/null || echo "")
    status="stopped"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      status="running"
    else
      status="not running"
    fi
    printf "%-12s %-8s %s\n" "$name" "$pid" "$status"
  done
else
  echo "No run directory found. No processes started via scripts/dev.sh"
fi

echo "\nRecent logs (tail -n 80)"
for log in "$LOG_DIR"/*.log; do
  [ -e "$log" ] || continue
  echo "---- $log ----"
  tail -n 80 "$log" || true
  echo
done
