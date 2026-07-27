#!/usr/bin/env bash
# Start the local preview/dev-link server. Runs in the foreground for a few
# minutes, holding the preview link open so your laptop can reach this sandbox.
set -euo pipefail
cd "$(dirname "$0")/.."
chmod +x ./devserver 2>/dev/null || true
exec ./devserver "$@"
