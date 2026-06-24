#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 -m py_compile "$ROOT/src/porua_openai_adapter.py"
find "$ROOT" -name __pycache__ -type d -prune -exec rm -rf {} +
python3 -m json.tool "$ROOT/extension/manifest.json" >/dev/null
python3 - "$ROOT" <<'PY'
import json
import re
import struct
import sys
from pathlib import Path

root = Path(sys.argv[1])
manifest = json.loads((root / "extension" / "manifest.json").read_text())

def png_size(path):
    with path.open("rb") as f:
        header = f.read(24)
    if header[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit(f"{path} is not a PNG")
    return struct.unpack(">II", header[16:24])

for size in (16, 32, 48, 128):
    name = f"icon{size}.png"
    path = root / "extension" / name
    if manifest["icons"].get(str(size)) != name:
        raise SystemExit(f"manifest icons.{size} must be {name}")
    if png_size(path) != (size, size):
        raise SystemExit(f"{path} must be {size}x{size}")

store_icon = root / "store-assets" / "store-icon-128.png"
if png_size(store_icon) != (128, 128):
    raise SystemExit(f"{store_icon} must be 128x128")

screenshots = sorted((root / "store-assets").glob("screenshot-*.png"))
if len(screenshots) < 1:
    raise SystemExit("at least one Chrome Web Store screenshot is required")
for screenshot in screenshots:
    if png_size(screenshot) != (1280, 800):
        raise SystemExit(f"{screenshot} must be 1280x800")

remote_url = re.compile(r"https?://(?!(?:localhost|127\.0\.0\.1)(?::|/))")
for path in (root / "extension").rglob("*"):
    if path.suffix not in {".html", ".js", ".json", ".css"}:
        continue
    content = path.read_text(errors="ignore")
    match = remote_url.search(content)
    if match:
        raise SystemExit(f"external URL is not allowed in extension package: {path}: {match.group(0)}")
PY
bash -n "$ROOT/scripts/install-mac.sh"
bash -n "$ROOT/scripts/uninstall-mac.sh"
bash -n "$ROOT/scripts/package-release.sh"
bash -n "$ROOT/Install.command"
bash -n "$ROOT/Uninstall.command"

echo "Checks passed."
