# Release Checklist

Use this before publishing a release.

## Local Checks

```bash
./scripts/check.sh
./scripts/package-release.sh
```

Confirm these generated files exist:

```text
dist/local-kokoro-reader-extension-v1.0.1.zip
dist/local-kokoro-reader-v1.0.1.zip
dist/local-kokoro-reader-store-assets-v1.0.1.zip
dist/store-assets/store-icon-128.png
dist/store-assets/screenshot-1-read-page.png
dist/store-assets/screenshot-2-selected-text.png
dist/store-assets/screenshot-3-local-private.png
dist/SHA256SUMS
```

## Manual Smoke Test

1. Double-click `Install.command`.
2. Confirm the local service starts:

```bash
curl http://127.0.0.1:8765/health
```

3. Load or install the Chrome extension.
4. Open a simple webpage.
5. Click Play.
6. Confirm audio plays.
7. Select text, right-click, choose Read Aloud.
8. Confirm audio plays.

## Publish

1. Push the repo to GitHub.
2. Create or update a GitHub release.
3. Attach `dist/local-kokoro-reader-v*.zip`.
4. Attach `dist/local-kokoro-reader-store-assets-v*.zip`.
5. Upload `dist/local-kokoro-reader-extension-v*.zip` to the Chrome Web Store.
6. Upload `dist/store-assets/store-icon-128.png` as the store icon.
7. Upload the `dist/store-assets/screenshot-*.png` files as screenshots.
8. Link the privacy policy from the public repo.
9. After Google assigns the item URL, rebuild with `WEB_STORE_URL=... ./scripts/package-release.sh` and update the GitHub release package.
