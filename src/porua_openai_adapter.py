#!/usr/bin/env python3
"""Small localhost adapter from OpenAI-compatible TTS requests to Porua."""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


DEFAULT_PORUA_URL = "http://127.0.0.1:3000/tts"


class AdapterHandler(BaseHTTPRequestHandler):
    server_version = "PoruaOpenAIAdapter/0.1"

    def _send_headers(self, status: int, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.end_headers()

    def do_OPTIONS(self) -> None:
        self._send_headers(204, "text/plain")

    def do_GET(self) -> None:
        if self.path in {"/health", "/v1/health"}:
            self._send_headers(200, "application/json")
            self.wfile.write(b'{"status":"ok","backend":"porua"}')
            return
        self._send_headers(404, "application/json")
        self.wfile.write(b'{"error":"not found"}')

    def do_POST(self) -> None:
        if self.path != "/v1/audio/speech":
            self._send_headers(404, "application/json")
            self.wfile.write(b'{"error":"not found"}')
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
            payload = json.loads(self.rfile.read(length) or b"{}")
            text = payload.get("input") or payload.get("text")
            if not isinstance(text, str) or not text.strip():
                raise ValueError("missing non-empty input text")

            porua_payload = {
                "text": text,
                "voice": payload.get("voice") or "bf_lily",
                "speed": float(payload.get("speed") or 1.0),
                "enable_chunking": True,
            }
            req = urllib.request.Request(
                self.server.porua_url,
                data=json.dumps(porua_payload).encode("utf-8"),
                headers={"Content-Type": "application/json", "Accept": "audio/wav"},
                method="POST",
            )
            with urllib.request.urlopen(req, timeout=self.server.timeout_seconds) as res:
                body = res.read()
                content_type = res.headers.get("Content-Type", "audio/wav")
                if body.startswith(b"RIFF"):
                    content_type = "audio/wav"

            self._send_headers(200, content_type)
            self.wfile.write(body)
        except (ValueError, json.JSONDecodeError) as exc:
            self._send_headers(400, "application/json")
            self.wfile.write(json.dumps({"error": str(exc)}).encode("utf-8"))
        except urllib.error.HTTPError as exc:
            self._send_headers(exc.code, "application/json")
            detail = exc.read().decode("utf-8", errors="replace")
            self.wfile.write(json.dumps({"error": detail}).encode("utf-8"))
        except Exception as exc:
            self._send_headers(502, "application/json")
            self.wfile.write(json.dumps({"error": str(exc)}).encode("utf-8"))

    def log_message(self, fmt: str, *args: object) -> None:
        print(f"{self.address_string()} - {fmt % args}", file=sys.stderr)


class AdapterServer(ThreadingHTTPServer):
    def __init__(self, address: tuple[str, int], porua_url: str, timeout_seconds: int):
        super().__init__(address, AdapterHandler)
        self.porua_url = porua_url
        self.timeout_seconds = timeout_seconds


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--porua-url", default=DEFAULT_PORUA_URL)
    parser.add_argument("--timeout-seconds", type=int, default=120)
    args = parser.parse_args()

    server = AdapterServer((args.host, args.port), args.porua_url, args.timeout_seconds)
    print(f"OpenAI-compatible TTS adapter: http://{args.host}:{args.port}/v1/audio/speech")
    print(f"Forwarding to Porua: {args.porua_url}")
    server.serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
