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

For a public release, users install the Chrome extension from the Chrome Web Store and then double-click `Install.command` to install the local voice service.

Until the Chrome Web Store listing is live, this repo also supports a local developer install.

### Current Local Install

1. Download this repo.
2. Double-click `Install.command`.
3. When Chrome opens `chrome://extensions/`, turn on **Developer mode**.
4. Click **Load unpacked**.
5. Choose the opened `chrome-extension` folder.
6. Pin **Local Kokoro TTS Reader** from Chrome's extensions menu.

Chrome requires the **Load unpacked** step for local extensions. The installer opens the right folder and page so there is nothing to search for.

### Final Public Install

The final nontechnical install path is:

1. Install the extension from the Chrome Web Store.
2. Double-click `Install.command` to install the local voice service.
3. Click the extension on any page and press Play.

The repo includes the extension package, store assets, privacy policy, and checklist needed for Chrome Web Store submission.

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

## Current Limitation

Chrome does not allow a script to silently install a local unpacked extension. That is why installation has one manual Chrome safety step.

For a truly one-click consumer extension install, publish the prepared extension package to the Chrome Web Store.

## Project Boundary

This project intentionally stays small:

- macOS only
- Chrome only
- local Kokoro voices only
- no cloud fallback
- no accounts
- no voice cloning
