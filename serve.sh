#!/bin/sh
# Serve this copy of the WebKitty host to the console.
#
#   ./serve.sh                      # port 8000
#   PORT=8080 ./serve.sh
#
# Differences from a plain `python3 -m http.server`:
#   * .manifest -> text/cache-manifest, the pages under includes/caches use
#     AppCache and WebKit refuses a manifest served as octet-stream.
#   * .bin / .elf -> application/octet-stream, so payloads are not sniffed.
#   * no-store on code, so a corrected file is never a cached one.

set -eu

cd "$(dirname "$0")"
PORT="${PORT:-8000}"

exec python3 - "$PORT" <<'PY'
import socket
import sys
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


def lan_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("10.255.255.255", 1))
        return s.getsockname()[0]
    except OSError:
        return "127.0.0.1"
    finally:
        s.close()


class Handler(SimpleHTTPRequestHandler):
    extensions_map = {
        **SimpleHTTPRequestHandler.extensions_map,
        ".js": "text/javascript",
        ".mjs": "text/javascript",
        ".css": "text/css",
        ".manifest": "text/cache-manifest",
        ".bin": "application/octet-stream",
        ".elf": "application/octet-stream",
    }

    CACHEABLE = (".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".svg", ".woff", ".woff2")

    def end_headers(self):
        if self.path.split("?")[0].lower().endswith(self.CACHEABLE):
            self.send_header("Cache-Control", "public, max-age=604800")
        else:
            self.send_header("Cache-Control", "no-store, must-revalidate")
            self.send_header("Pragma", "no-cache")
            self.send_header("Expires", "0")
        super().end_headers()

    def log_message(self, fmt, *args):
        sys.stderr.write("%s %s\n" % (self.address_string(), fmt % args))


port = int(sys.argv[1])
server = ThreadingHTTPServer(("0.0.0.0", port), partial(Handler, directory="."))
print("webkitty (local) on http://%s:%d/  (ctrl-c to stop)" % (lan_ip(), port), flush=True)
try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
PY
