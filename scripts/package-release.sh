#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT/dist"
VERSION="$(python3 -c 'import json; print(json.load(open("'"$ROOT"'/extension/manifest.json"))["version"])')"
WEB_STORE_URL_FILE="$ROOT/WEB_STORE_URL.txt"
REMOVE_WEB_STORE_URL_FILE=0

cleanup() {
  if [[ "$REMOVE_WEB_STORE_URL_FILE" == "1" ]]; then
    rm -f "$WEB_STORE_URL_FILE"
  fi
}
trap cleanup EXIT

rm -rf "$DIST"
mkdir -p "$DIST"

find "$ROOT" -name __pycache__ -type d -prune -exec rm -rf {} +

(
  cd "$ROOT/extension"
  zip -qr "$DIST/local-kokoro-reader-extension-v${VERSION}.zip" .
)

if [[ -n "${WEB_STORE_URL:-}" && ! -f "$WEB_STORE_URL_FILE" ]]; then
  printf '%s\n' "$WEB_STORE_URL" > "$WEB_STORE_URL_FILE"
  REMOVE_WEB_STORE_URL_FILE=1
fi

(
  cd "$ROOT/.."
  zip -qr "$DIST/local-kokoro-reader-v${VERSION}.zip" local-kokoro-reader \
    -x 'local-kokoro-reader/.git/*' \
    -x 'local-kokoro-reader/dist/*' \
    -x '*/__pycache__/*' \
    -x '*/.DS_Store'
)

cp -R "$ROOT/store-assets" "$DIST/store-assets"
(
  cd "$ROOT"
  zip -qr "$DIST/local-kokoro-reader-store-assets-v${VERSION}.zip" store-assets
)
shasum -a 256 "$DIST"/*.zip > "$DIST/SHA256SUMS"

echo "Created release files:"
ls -lh "$DIST"
