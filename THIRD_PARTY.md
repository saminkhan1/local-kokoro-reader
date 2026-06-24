# Third-Party Components

This project keeps the installer thin and reuses existing local TTS work.

## Porua

- Project: https://github.com/ShahadIshraq/porua
- Role: local Rust HTTP server for Kokoro TTS
- License: MIT
- Downloaded by the installer from Porua GitHub releases

## Kokoro-82M

- Model: https://huggingface.co/hexgrad/Kokoro-82M
- ONNX files: https://github.com/thewh1teagle/kokoro-onnx
- Role: local text-to-speech model and voice vectors
- License: Apache-2.0 for Kokoro-82M model files
- Downloaded by the installer; model weights are not committed to this repo

## local_tts_reader

- Project: https://github.com/phildougherty/local_tts_reader
- Role: original Chrome extension UI and playback flow
- License: README states MIT
- Local changes in this repo: localhost-only default, Lily voice option, readable-text fallback, and narrowed host permissions
