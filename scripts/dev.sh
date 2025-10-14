#!/usr/bin/env bash
set -euo pipefail

# Small helper to start the Laravel backend, queue workers and the frontend dev server
# Runs processes with nohup, records PIDs in ./run and logs in ./logs

BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
RUN_DIR="$BASEDIR/run"
LOG_DIR="$BASEDIR/logs"

mkdir -p "$RUN_DIR" "$LOG_DIR"

start_if_needed() {
  name="$1"
  shift
  cmd="$@"
  pidfile="$RUN_DIR/${name}.pid"
  logfile="$LOG_DIR/${name}.log"

  if [ -f "$pidfile" ]; then
    pid=$(cat "$pidfile" 2>/dev/null || echo "")
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      echo "$name already running (pid $pid). Skipping start."
      return
    else
      echo "Removing stale pidfile for $name"
      rm -f "$pidfile"
    fi
  fi

  echo "Starting $name -> logging to $logfile"
  # start in a subshell to ensure working dir/local env is correct
  nohup bash -lc "$cmd" > "$logfile" 2>&1 &
  pid=$!
  echo $pid > "$pidfile"
  # give it a moment
  sleep 0.6
  echo "$name started with pid $pid"
}

echo "Starting development services (backend, queue, pail, frontend)"


# Choose an available port for the backend (try 8000..8010)
choose_port() {
  for p in $(seq 8000 8010); do
    if ! ss -ltn "sport = :$p" 2>/dev/null | grep -q ':\'"$p"; then
      echo $p
      return
    fi
  done
  # fallback
  echo 8000
}

BACKEND_PORT=$(choose_port)

# If the selected port is occupied by a process, attempt to stop it (automated)
if ss -ltn "sport = :$BACKEND_PORT" 2>/dev/null | grep -q ':'"$BACKEND_PORT"; then
  echo "Port $BACKEND_PORT appears in use. Attempting to find the process occupying it."
  pid=$(ss -ltnp "sport = :$BACKEND_PORT" 2>/dev/null | sed -n '2p' | awk -F"pid=" '{print $2}' | awk -F"," '{print $1}' | tr -d ' ') || true
  if [ -n "$pid" ]; then
    # If running interactively, ask for confirmation. Otherwise proceed to kill automatically.
    if [ -t 0 ]; then
      read -r -p "Found process $pid on port $BACKEND_PORT. Kill it? [y/N] " answer || answer="n"
      case "$answer" in
        [yY]|[yY][eE][sS])
          echo "Killing process $pid on port $BACKEND_PORT"
          kill "$pid" || true
          sleep 0.4
          ;;
        *)
          echo "User declined to kill process. Exiting to avoid interfering with existing service."
          exit 1
          ;;
      esac
    else
      echo "Non-interactive shell: killing process $pid on port $BACKEND_PORT"
      kill "$pid" || true
      sleep 0.4
    fi
  fi
fi

echo "Starting backend on port $BACKEND_PORT"
start_if_needed backend "cd '$BASEDIR/backend' && php artisan serve --host=127.0.0.1 --port=$BACKEND_PORT"

# Queue listener
start_if_needed queue "cd '$BASEDIR/backend' && php artisan queue:listen --tries=1"

# Pail (if available)
start_if_needed pail "cd '$BASEDIR/backend' && php artisan pail --timeout=0"

# Frontend (vite) with VITE_PROXY_TARGET pointing to the backend
export VITE_PROXY_TARGET="http://127.0.0.1:$BACKEND_PORT"
echo "Starting frontend with VITE_PROXY_TARGET=$VITE_PROXY_TARGET"
start_if_needed frontend "cd '$BASEDIR/frontend' && VITE_PROXY_TARGET='$VITE_PROXY_TARGET' npm run dev"

# Attempt to discover the frontend URL from the vite log and open it in the default browser
sleep 0.8
frontend_url=""
if [ -f "$LOG_DIR/frontend.log" ]; then
  # Try to find the last http://localhost:PORT reported by Vite
  frontend_url=$(grep -oE 'http://localhost:[0-9]+' "$LOG_DIR/frontend.log" | tail -n1 || true)
fi
if [ -z "$frontend_url" ]; then
  frontend_url="http://localhost:5173"
fi
echo "Frontend likely available at: $frontend_url"
# open browser if possible and running in interactive mode
if command -v xdg-open >/dev/null 2>&1 && [ -t 0 ]; then
  echo "Opening $frontend_url in default browser..."
  xdg-open "$frontend_url" >/dev/null 2>&1 || true
fi

echo "All requested processes have been (attempted) started. Logs: $LOG_DIR, PIDs: $RUN_DIR"
echo "Use scripts/status.sh to check logs or scripts/stop.sh to stop them."
