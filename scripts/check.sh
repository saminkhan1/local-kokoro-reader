#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 -m py_compile "$ROOT/src/porua_openai_adapter.py"
find "$ROOT" -name __pycache__ -type d -prune -exec rm -rf {} +
python3 -m json.tool "$ROOT/extension/manifest.json" >/dev/null
bash -n "$ROOT/scripts/install-mac.sh"
bash -n "$ROOT/scripts/uninstall-mac.sh"
bash -n "$ROOT/Install.command"
bash -n "$ROOT/Uninstall.command"

echo "Checks passed."
