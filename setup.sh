#!/usr/bin/env bash
  set -x
  echo "CUSTOM_SETUP_RAN $(date)"

  # 1. Install cloudflared
  [ -x /usr/local/bin/cloudflared ] || {
    wget -q -T 60 https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared
  }
  echo "CF=$?"

  # 2. Write proxy (forwards /<path> -> https://chatgpt.com:18080/backend-api/codex/<path>)
  cat > /usr/local/bin/proxy.py << 'PYEOF'
  import urllib.request, ssl
  from http.server import BaseHTTPRequestHandler, HTTPServer
  class H(BaseHTTPRequestHandler):
      def _f(self, m):
          l = int(self.headers.get('content-length') or 0)
    def _f(self, m):
        l = int(self.headers.get('content-length') or 0)
        b = self.rfile.read(l) if l else None
        u = 'https://chatgpt.com:18080/backend-api/codex' + self.path
        h = {'content-type': 'application/json'}
        for k in ('originator', 'version', 'openai-beta', 'x-codex-beta-features', 'chatgpt-account-id'):
            v = self.headers.get(k)
            if v: h[k] = v
        try:
            r = urllib.request.urlopen(urllib.request.Request(u, data=b, headers=h, method=m), context=ssl._create_unverified_context())
            self.send_response(200)
            self.send_header('content-type', r.headers.get('content-type', 'text/event-stream'))
            self.end_headers()
            while True:
                c = r.read(4096)
                if not c: break
                self.wfile.write(c); self.wfile.flush()
        except urllib.error.HTTPError as e:
            self.send_response(e.code); self.end_headers(); self.wfile.write(e.read())
        except Exception as e:
            self.send_response(502); self.end_headers(); self.wfile.write(('E ' + str(e)).encode())
    def do_POST(self): self._f('POST')
    def do_GET(self):
        if self.path == '/health': self.send_response(200); self.end_headers(); self.wfile.write(b'ok'); return
        self._f('GET')
    def log_message(self, *a): pass
HTTPServer(('0.0.0.0', 9999), H).serve_forever()
PYEOF

# 3. Start proxy + cloudflared tunnel
nohup python3 /usr/local/bin/proxy.py > /var/log/proxy.log 2>&1 &
sleep 2
nohup /usr/local/bin/cloudflared tunnel --protocol http2 --url http://localhost:9999 > /var/log/tunnel.log 2>&1 &
sleep 12
TUNNEL_URL=$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' /var/log/tunnel.log 2>/dev/null | grep -v 'api\.' | head -1)
echo "TUNNEL_URL=$TUNNEL_URL"
echo "$TUNNEL_URL" > /workspace/test/TUNNEL_URL.txt
echo "SETUP_COMPLETE"
