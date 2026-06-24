# Chrome Web Store Submission

Publishing the extension is the path to a normal install for nontechnical users.

Until it is published, Chrome requires the local **Load unpacked** developer-mode step. That is not good enough for the final target user.

## Package

Run:

```bash
./scripts/package-release.sh
```

Upload this file to the Chrome Web Store developer dashboard:

```text
dist/local-kokoro-reader-extension-v1.0.zip
```

Use these listing assets:

```text
dist/store-assets/store-icon-128.png
dist/store-assets/screenshot-1-read-page.png
dist/store-assets/screenshot-2-selected-text.png
dist/store-assets/screenshot-3-local-private.png
```

## Suggested Listing

Name:

```text
Local Kokoro TTS Reader
```

Short description:

```text
Read Chrome pages aloud with a private local Kokoro voice on your Mac.
```

Long description:

```text
Local Kokoro TTS Reader adds a simple read-aloud button to Chrome.

It uses a local voice service running on your Mac. There is no subscription, no account, no paid API, and no cloud text-to-speech service.

Use it to read selected text or page text aloud. The companion Mac installer starts the local voice service and keeps it running in the background.
```

Category:

```text
Accessibility
```

Privacy practices:

```text
The extension does not collect, sell, rent, or share user data. It sends selected/page text only to localhost on the user's Mac for local speech generation.
```

Host permissions explanation:

```text
The extension needs localhost access to send text to the local voice service running on the user's Mac. It uses activeTab and scripting so it can read selected text or page text only when the user activates the extension.
```

Single purpose:

```text
Read webpage text aloud using a private local voice service running on the user's Mac.
```

Data usage certification:

```text
This extension does not collect or transmit user data to the developer or any third party. Page text is sent only to localhost for user-requested speech generation.
```

## URLs Needed From The Public Repo

- Privacy policy URL: `docs/PRIVACY_POLICY.md`
- Support URL: GitHub issues page

## After Approval

Update `scripts/install-mac.sh` to open the Chrome Web Store URL instead of `chrome://extensions/`.
