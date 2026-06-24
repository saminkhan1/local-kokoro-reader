# Privacy Policy

Local Kokoro TTS Reader reads webpage text aloud using a local voice service on your Mac.

## Data Collection

This project does not collect, sell, rent, or share personal data.

## What The Extension Reads

When you click Play or choose Read Aloud, the extension reads the selected text or visible page text needed for speech.

## Where Text Goes

The extension sends text only to:

```text
http://localhost:8765/v1/audio/speech
```

That address is on your own Mac. The local adapter forwards the text to:

```text
http://127.0.0.1:3000/tts
```

That is also on your own Mac.

## Network Access

The installer downloads the local voice engine and model files during setup. After setup, speech generation runs locally.

## Storage

The extension stores simple settings in Chrome, such as voice, speed, and local server URL. It does not store webpage text.

## Contact

For open-source releases, use the repository issue tracker.
