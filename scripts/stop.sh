#!/usr/bin/env bash
set -euo pipefail

BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
RUN_DIR="$BASEDIR/run"
LOG_DIR="$BASEDIR/logs"

if [ ! -d "$RUN_DIR" ]; then
  echo "No run directory found (nothing to stop)."
  exit 0
fi

for f in "$RUN_DIR"/*.pid; do
  [ -e "$f" ] || continue
  name=$(basename "$f" .pid)
  pid=$(cat "$f" 2>/dev/null || echo "")
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    echo "Stopping $name (pid $pid)"
    kill "$pid" || true
    # give it some time
    sleep 0.3
    if kill -0 "$pid" 2>/dev/null; then
      echo "$name did not exit, forcing kill"
      kill -9 "$pid" || true
    fi
  else
    echo "$name not running (stale pidfile)."
  fi
  rm -f "$f"
done

echo "Stopped processes and removed pidfiles. Logs remain in $LOG_DIR"
