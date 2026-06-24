# Contributing

Keep this project boring and easy.

The target user is a nontechnical Mac user who wants to click once in Chrome and hear a page read aloud locally. Prefer fixes that reduce setup steps, confusing states, or support burden.

## Scope

In scope:

- More reliable macOS install/uninstall
- Better Chrome extension clarity
- Simpler troubleshooting
- Safer local-only defaults
- Updating to newer local Kokoro-compatible engines when clearly better

Out of scope for now:

- Cloud voices
- Paid APIs
- Accounts or sync
- Voice cloning
- Multi-browser support
- Large GUI rewrites

## Checks

Run:

```bash
./scripts/check.sh
```

Do not commit downloaded model files, logs, or generated audio.
