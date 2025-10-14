# Dev helper scripts

This folder contains helper scripts to make local development easier by starting the backend, queue and frontend dev servers together.

Files
- `dev.sh` - starts the Laravel backend (`php artisan serve`), queue listener (`php artisan queue:listen`), `php artisan pail` and the frontend dev server (`npm run dev`).
  - Chooses a free port for the backend between 8000–8010.
  - If a process is found on the chosen port, the script will ask for confirmation (interactive shells) before killing it.
  - Exports `VITE_PROXY_TARGET` so the frontend Vite server proxies `/api` to the correct backend URL.
  - Logs go to `../logs/*.log` and PIDs to `../run/*.pid`.
- `status.sh` - shows the pid/status and tails recent logs.
- `stop.sh` - stops processes started by `dev.sh` and removes pidfiles.

Basic usage

Start everything:
```bash
./scripts/dev.sh
```

Check status and view logs:
```bash
./scripts/status.sh
```

Stop everything started by `dev.sh`:
```bash
./scripts/stop.sh
```

Notes and safety
- The script attempts to be helpful and may kill a process occupying the selected backend port. It prompts before doing so in interactive shells. If you run it from CI or non-interactive shells it will kill automatically.
- Logs are kept under `logs/` so you can inspect outputs if something fails.
- If you want more conservative behavior (never kill processes automatically), edit `dev.sh` and remove the kill path or implement a confirmation-only flow.
