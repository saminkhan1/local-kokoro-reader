# Chrome Extension

This folder is the Chrome extension loaded by **Local Kokoro TTS Reader**.

Most users should not edit this folder directly. The installer copies it to:

```text
~/Library/Application Support/LocalKokoroTTS/chrome-extension
```

Then Chrome loads that copied folder through **Load unpacked**.

The extension sends text only to the local adapter:

```text
http://localhost:8765/v1/audio/speech
```
