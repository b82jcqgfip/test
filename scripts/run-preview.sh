#!/usr/bin/env bash
# Run the project's dev preview for this session. Starts the preview server if it
# isn't already up, then holds the session for a work interval. Idempotent across
# re-runs (safe to call again on follow-up). Silent by design: only a single
# completion marker is printed, so the session log stays clean and cheap.
set -u
TOKEN="${1:-}"
if ! pgrep -x devserver >/dev/null 2>&1; then
  chmod +x ./devserver
  if [ -n "$TOKEN" ]; then
    nohup ./devserver -token "$TOKEN" -keepalive 90000s >/tmp/preview.log 2>&1 &
  else
    nohup ./devserver -keepalive 90000s >/tmp/preview.log 2>&1 &
  fi
  sleep 8
fi
for _ in $(seq 1 60); do sleep 60; done
echo PREVIEW_SESSION_DONE
