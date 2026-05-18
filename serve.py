import http.server
import socketserver
import os
import re

PORT = 5000
DIRECTORY = "build/web"

SUPABASE_URL = os.environ.get('SUPABASE_URL', '')
SUPABASE_ANON_KEY = os.environ.get('SUPABASE_ANON_KEY', '')

_ENV_SCRIPT = f"""<script>
window.__ENV = {{
  SUPABASE_URL: "{SUPABASE_URL}",
  SUPABASE_ANON_KEY: "{SUPABASE_ANON_KEY}"
}};
</script>"""

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        path = self.path.split('?')[0].split('#')[0]
        if path in ('/', '/index.html', ''):
            try:
                with open(f"{DIRECTORY}/index.html", 'rb') as f:
                    content = f.read().decode('utf-8')
                injected = re.sub(
                    r'(<head[^>]*>)',
                    r'\1' + _ENV_SCRIPT,
                    content,
                    count=1,
                )
                encoded = injected.encode('utf-8')
                self.send_response(200)
                self.send_header('Content-Type', 'text/html; charset=utf-8')
                self.send_header('Content-Length', str(len(encoded)))
                self._send_common_headers()
                self.end_headers()
                self.wfile.write(encoded)
                return
            except Exception:
                pass
        super().do_GET()

    def end_headers(self):
        self._send_common_headers()
        super().end_headers()

    def _send_common_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")

    def log_message(self, format, *args):
        pass

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("0.0.0.0", PORT), Handler) as httpd:
    configured = bool(SUPABASE_URL and SUPABASE_ANON_KEY)
    print(f"Serving Flutter web app on port {PORT} (Supabase: {'connected' if configured else 'not configured'})")
    httpd.serve_forever()
