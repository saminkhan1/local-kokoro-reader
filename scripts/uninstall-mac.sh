#!/usr/bin/env bash
set -euo pipefail

SERVICE_LABEL="com.local-kokoro-reader.tts"
INSTALL_ROOT="$HOME/Library/Application Support/LocalKokoroTTS"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/${SERVICE_LABEL}.plist"

echo "Stopping Local Kokoro TTS Reader..."
launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT" >/dev/null 2>&1 || true
pkill -f 'porua_server --server --port 3000' >/dev/null 2>&1 || true
pkill -f 'porua_openai_adapter.py' >/dev/null 2>&1 || true

rm -f "$LAUNCH_AGENT"
rm -rf "$INSTALL_ROOT"

echo "Removed the local voice service."
echo "Chrome may still show the extension until you remove it from chrome://extensions/."
