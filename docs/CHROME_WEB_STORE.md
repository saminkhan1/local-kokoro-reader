# Chrome Web Store Submission

Publishing the extension is the path to a normal install for nontechnical users.

Until it is published, Chrome requires the local **Load unpacked** developer-mode step. That is not good enough for the final target user.

## Package

Run:

```bash
./scripts/package-release.sh
```

After Google assigns the extension item ID, build the final user release with the Web Store URL embedded:

```bash
WEB_STORE_URL="https://chromewebstore.google.com/detail/local-kokoro-tts-reader/<item-id>" ./scripts/package-release.sh
```

Upload this file to the Chrome Web Store developer dashboard:

```text
dist/local-kokoro-reader-extension-v1.0.2.zip
```

Use these listing assets:

```text
dist/store-assets/store-icon-128.png
dist/store-assets/screenshot-1-read-page.png
dist/store-assets/screenshot-2-selected-text.png
dist/store-assets/screenshot-3-local-private.png
```

The same assets are also packaged as:

```text
dist/local-kokoro-reader-store-assets-v1.0.2.zip
```

Attach this GitHub release file for normal Mac users:

```text
dist/local-kokoro-reader-mac-installer-v1.0.2.zip
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

Language:

```text
English (United States)
```

Privacy practices:

```text
The extension does not collect, sell, rent, or share user data. It sends selected/page text only to localhost on the user's Mac for local speech generation.
```

Host permissions explanation:

```text
The extension needs localhost access to send text to the local voice service running on the user's Mac. It uses activeTab and scripting so it can read selected text or page text only when the user activates the extension.
```

Permission justifications:

```text
activeTab: Lets the extension read the current tab only after the user clicks the extension or chooses Read Aloud.
scripting: Extracts selected text or readable page text from the active tab after user action.
storage: Saves simple local settings such as voice and speed.
offscreen: Plays generated speech in the background while the popup is closed.
contextMenus: Adds the Read Aloud option for selected text.
```

Single purpose:

```text
Read webpage text aloud using a private local voice service running on the user's Mac.
```

Data usage certification:

```text
This extension does not collect or transmit user data to the developer or any third party. Page text is sent only to localhost for user-requested speech generation.
```

User data category:

```text
Website content
```

User data usage:

```text
Website content is read only when the user clicks Play or chooses Read Aloud. It is sent to localhost on the user's Mac to generate speech. It is not collected by the developer, sold, shared, or used for advertising.
```

## URLs Needed From The Public Repo

- Privacy policy URL: `https://github.com/saminkhan1/local-kokoro-reader/blob/main/docs/PRIVACY_POLICY.md`
- Support URL: `https://github.com/saminkhan1/local-kokoro-reader/issues`
- Homepage URL: `https://github.com/saminkhan1/local-kokoro-reader`

## Current Upload Gate

The repo, extension zip, privacy policy, screenshots, and release package are ready. The remaining browser step is Google account verification in the Chrome Web Store Developer Dashboard.

## After The Web Store URL Exists

The installer is public-user first by default. Build the final release package with the Web Store URL:

```bash
WEB_STORE_URL="https://chromewebstore.google.com/detail/local-kokoro-tts-reader/<item-id>" ./scripts/package-release.sh
```

Local developer testing still uses:

```bash
./Install.command --local-extension
```
