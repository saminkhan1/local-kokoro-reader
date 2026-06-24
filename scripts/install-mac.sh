#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Local Kokoro TTS Reader"
SERVICE_LABEL="com.local-kokoro-reader.tts"
SERVER_VERSION="v0.2.0"
SERVER_ARCHIVE="porua_server-${SERVER_VERSION}-macos-arm64.tar.gz"
SERVER_URL="https://github.com/ShahadIshraq/porua/releases/download/server-${SERVER_VERSION}/porua_server-${SERVER_VERSION}-macos-arm64.tar.gz"
SERVER_SHA256="495dab24f9051773909cbf847d13abb00607ab9b326825e7c80f6912ec2df06e"
MODEL_BASE_URL="https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0"
WEB_STORE_URL="${WEB_STORE_URL:-}"
LOCAL_EXTENSION_MODE=0

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_ROOT="$HOME/Library/Application Support/LocalKokoroTTS"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/${SERVICE_LABEL}.plist"
LOG_DIR="$INSTALL_ROOT/logs"
EXTENSION_DIR="$INSTALL_ROOT/chrome-extension"

if [[ -z "$WEB_STORE_URL" && -f "$REPO_ROOT/WEB_STORE_URL.txt" ]]; then
  WEB_STORE_URL="$(tr -d '\r\n' < "$REPO_ROOT/WEB_STORE_URL.txt")"
fi

info() {
  printf "\033[1;34m%s\033[0m\n" "$1"
}

success() {
  printf "\033[1;32m%s\033[0m\n" "$1"
}

fail() {
  printf "\033[1;31m%s\033[0m\n" "$1" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

parse_args() {
  for arg in "$@"; do
    case "$arg" in
      --local-extension)
        LOCAL_EXTENSION_MODE=1
        ;;
      *)
        fail "Unknown option: $arg"
        ;;
    esac
  done
}

check_machine() {
  [[ "$(uname -s)" == "Darwin" ]] || fail "This installer is for macOS."
  [[ "$(uname -m)" == "arm64" ]] || fail "This installer currently supports Apple Silicon Macs only."
  [[ -d "/Applications/Google Chrome.app" ]] || fail "Google Chrome is not installed. Install Chrome first, then run this installer again."
}

download() {
  local url="$1"
  local output="$2"
  if [[ -f "$output" ]]; then
    return 0
  fi
  curl -L --fail --progress-bar "$url" -o "$output"
}

verify_sha256() {
  local expected="$1"
  local file="$2"
  local actual
  actual="$(shasum -a 256 "$file" | awk '{print $1}')"
  [[ "$actual" == "$expected" ]] || fail "Checksum mismatch for $file"
}

write_runner() {
  cat > "$INSTALL_ROOT/run-local-tts-services.sh" <<'RUNNER'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Library/Application Support/LocalKokoroTTS"
LOG_DIR="$ROOT/logs"
mkdir -p "$LOG_DIR"

PORUA_PID=""
ADAPTER_PID=""

cleanup() {
  if [[ -n "$ADAPTER_PID" ]]; then kill "$ADAPTER_PID" >/dev/null 2>&1 || true; fi
  if [[ -n "$PORUA_PID" ]]; then kill "$PORUA_PID" >/dev/null 2>&1 || true; fi
}
trap cleanup EXIT INT TERM

cd "$ROOT/porua/server"
TTS_POOL_SIZE="${TTS_POOL_SIZE:-4}" RUST_LOG="${RUST_LOG:-warn}" ./bin/porua_server --server --port 3000 \
  >>"$LOG_DIR/porua.log" 2>&1 &
PORUA_PID="$!"

for _ in {1..120}; do
  if curl -fsS http://127.0.0.1:3000/health >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "$PORUA_PID" >/dev/null 2>&1; then
    echo "Porua server exited before becoming healthy" >&2
    exit 1
  fi
  sleep 1
done

/usr/bin/python3 "$ROOT/porua_openai_adapter.py" >>"$LOG_DIR/adapter.log" 2>&1 &
ADAPTER_PID="$!"

for _ in {1..30}; do
  if curl -fsS http://127.0.0.1:8765/health >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "$ADAPTER_PID" >/dev/null 2>&1; then
    echo "Adapter exited before becoming healthy" >&2
    exit 1
  fi
  sleep 1
done

while true; do
  if ! kill -0 "$PORUA_PID" >/dev/null 2>&1; then
    echo "Porua server exited" >&2
    exit 1
  fi
  if ! kill -0 "$ADAPTER_PID" >/dev/null 2>&1; then
    echo "Adapter exited" >&2
    exit 1
  fi
  sleep 5
done
RUNNER
  chmod +x "$INSTALL_ROOT/run-local-tts-services.sh"
}

write_plist() {
  mkdir -p "$HOME/Library/LaunchAgents"
  cat > "$LAUNCH_AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${SERVICE_LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${INSTALL_ROOT}/run-local-tts-services.sh</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>${LOG_DIR}/launchd.out.log</string>
  <key>StandardErrorPath</key>
  <string>${LOG_DIR}/launchd.err.log</string>
  <key>WorkingDirectory</key>
  <string>${INSTALL_ROOT}</string>
</dict>
</plist>
PLIST
}

load_service() {
  launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT" >/dev/null 2>&1 || true
  pkill -f 'porua_server --server --port 3000' >/dev/null 2>&1 || true
  pkill -f 'porua_openai_adapter.py' >/dev/null 2>&1 || true
  launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT"
  launchctl enable "gui/$(id -u)/${SERVICE_LABEL}"
  launchctl kickstart -k "gui/$(id -u)/${SERVICE_LABEL}"
}

wait_for_service() {
  for _ in {1..120}; do
    if curl -fsS http://127.0.0.1:3000/health >/dev/null 2>&1 \
      && curl -fsS http://127.0.0.1:8765/health >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  tail -80 "$LOG_DIR/launchd.err.log" 2>/dev/null || true
  tail -80 "$LOG_DIR/porua.log" 2>/dev/null || true
  tail -80 "$LOG_DIR/adapter.log" 2>/dev/null || true
  fail "The local voice service did not start."
}

open_chrome_setup() {
  if [[ "$LOCAL_EXTENSION_MODE" == "1" ]]; then
    open -a "Google Chrome" "chrome://extensions/" || true
    open "$EXTENSION_DIR" || true
    osascript <<OSA >/dev/null 2>&1 || true
display dialog "The local voice is installed and running.\n\nOne Chrome safety step remains:\n1. In Chrome, turn on Developer mode.\n2. Click Load unpacked.\n3. Choose the opened chrome-extension folder.\n\nAfter that, pin Local Kokoro TTS Reader and click it on any page." buttons {"OK"} default button "OK" with title "$APP_NAME"
OSA
    return 0
  fi

  if [[ -n "$WEB_STORE_URL" ]]; then
    open -a "Google Chrome" "$WEB_STORE_URL" || true
    osascript <<OSA >/dev/null 2>&1 || true
display dialog "The local voice is installed and running.\n\nIf Chrome opened the Web Store page, click Add to Chrome.\n\nThen open any page, click Local Kokoro TTS Reader, and press Play." buttons {"OK"} default button "OK" with title "$APP_NAME"
OSA
    return 0
  fi

  osascript <<OSA >/dev/null 2>&1 || true
display dialog "The local voice is installed and running.\n\nNow install Local Kokoro TTS Reader from the Chrome Web Store.\n\nThen open any page, click the extension, and press Play." buttons {"OK"} default button "OK" with title "$APP_NAME"
OSA
}

parse_args "$@"
need_cmd curl
need_cmd shasum
need_cmd tar
need_cmd launchctl
check_machine

info "Installing $APP_NAME..."
mkdir -p "$INSTALL_ROOT/downloads" "$LOG_DIR"

info "Installing the Chrome extension files..."
rm -rf "$EXTENSION_DIR"
mkdir -p "$EXTENSION_DIR"
ditto "$REPO_ROOT/extension" "$EXTENSION_DIR"
cp "$REPO_ROOT/src/porua_openai_adapter.py" "$INSTALL_ROOT/porua_openai_adapter.py"

info "Downloading the local voice engine..."
download "$SERVER_URL" "$INSTALL_ROOT/downloads/$SERVER_ARCHIVE"
verify_sha256 "$SERVER_SHA256" "$INSTALL_ROOT/downloads/$SERVER_ARCHIVE"
rm -rf "$INSTALL_ROOT/porua"
mkdir -p "$INSTALL_ROOT/porua/server"
tar -xzf "$INSTALL_ROOT/downloads/$SERVER_ARCHIVE" -C "$INSTALL_ROOT/porua/server" --strip-components=1

info "Downloading Kokoro voice model files..."
mkdir -p "$INSTALL_ROOT/porua/server/models"
download "$MODEL_BASE_URL/kokoro-v1.0.onnx" "$INSTALL_ROOT/porua/server/models/kokoro-v1.0.onnx"
download "$MODEL_BASE_URL/voices-v1.0.bin" "$INSTALL_ROOT/porua/server/models/voices-v1.0.bin"

info "Starting the local voice service..."
write_runner
write_plist
load_service
wait_for_service

success "Local Kokoro voice service is running."
echo
echo "Chrome extension folder:"
echo "$EXTENSION_DIR"
echo
open_chrome_setup
success "Done. Open Chrome, click Local Kokoro TTS Reader, and press Play."
