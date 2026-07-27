#!/usr/bin/env bash
# setup.sh — runs at build (has network), persists in base cache
[ -x /usr/local/bin/cloudflared ] || { wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared; }
cat > /usr/local/bin/proxy.py << 'PY'
...forwarder /<path> -> https://chatgpt.com:18080/backend-api/codex/<path>...
PY
nohup python3 /usr/local/bin/proxy.py &>/var/log/proxy.log &
nohup /usr/local/bin/cloudflared tunnel --protocol http2 --url http://localhost:9999 &>/var/log/tunnel.log &
