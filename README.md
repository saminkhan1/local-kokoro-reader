# Local Kokoro TTS Reader

Free, local text-to-speech for reading Chrome pages aloud on a Mac.

This is for people who want a private read-aloud button without a subscription, cloud account, or usage limit. Speech is generated on your Mac with Kokoro through a local server.

## What You Get

- Local neural voice quality with Kokoro
- Chrome extension for selected text or page text
- No paid API
- No cloud voice service
- No account
- Starts automatically after install

## Requirements

- Apple Silicon Mac
- Google Chrome
- Internet for first install only, to download the local voice engine and model files

After installation, reading pages aloud runs locally.

## Install

The public install path is:

1. Install the extension from the Chrome Web Store.
2. Double-click `Install.command` to install the local voice service.
3. Click the extension on any page and press Play.

The repo includes the extension package, store assets, privacy policy, and checklist needed for Chrome Web Store submission.

### Local Developer Install

Until the Chrome Web Store listing is live, developers can test the extension locally:

```bash
./Install.command --local-extension
```

Chrome requires Developer Mode for unpacked local extensions. Normal users should use the Chrome Web Store install instead.

## Everyday Use

This is all the reader does after setup:

1. Open Chrome.
2. Open a webpage.
3. Click **Local Kokoro TTS Reader**.
4. Click Play.

The local voice service starts by itself when the Mac logs in.

## Use

Read a full page:

1. Open a webpage in Chrome.
2. Click the **Local Kokoro TTS Reader** icon.
3. Click Play.

Read selected text:

1. Select text on a webpage.
2. Right-click.
3. Choose **Read Aloud**.

## If It Does Not Speak

Check the local service:

```bash
curl http://127.0.0.1:8765/health
```

Expected:

```json
{"status":"ok","backend":"porua"}
```

Restart it:

```bash
launchctl kickstart -k gui/$(id -u)/com.local-kokoro-reader.tts
```

## Uninstall

Double-click `Uninstall.command`.

Then remove the Chrome extension from `chrome://extensions/`.

## Privacy

The extension sends page text only to `http://localhost:8765` on your own Mac. The local adapter forwards it to `http://127.0.0.1:3000`, also on your Mac.

No text is sent to a paid API or cloud TTS service by this project.

## Project Boundary

This project intentionally stays small:

- macOS only
- Chrome only
- local Kokoro voices only
- no cloud fallback
- no accounts
- no voice cloning
