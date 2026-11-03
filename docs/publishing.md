# Publishing plan

1. Review the [0.1.0 release checklist](release-review.md) and pass the
   remaining [physical device checks](testing.md) before submission.
2. Build the extension with `npm ci --ignore-scripts && npm run build`. Run
   `mkdir -p .build && (cd dist && zip -X ../.build/airdrop-extension.zip manifest.json background.js)`.
   The manifest must be at the archive root. Add original icons, screenshots,
   a public [privacy policy](privacy.md), and reviewer instructions for the helper.
3. Create a draft in the [Chrome Web Store Developer Dashboard](https://developer.chrome.com/docs/webstore/publish).
   Obtain the assigned extension ID. Disclose the separate native installation
   and why each browser permission is needed. Test with the actual store ID and
   the packaged build before seeking public review.
4. Create a macOS installer for the helper and exact store origin. Install the
   manifests in the user's Brave and Chrome native host directories as that
   user, without replacing an existing registration. Sign the native executable with Developer ID
   Application and a distributed installer package with Developer ID Installer.
   [Notarize and staple](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
   the distributed package and test it on a clean Mac with Gatekeeper enabled.
   Put the verified installer and checksum on GitHub Releases, and link it from
   the store listing and reviewer instructions.

The Chrome Web Store installs the browser extension; it cannot install the
native host. Brave users can install compatible Chrome Web Store extensions.
The source installer is for local development. No store submission, signed
installer, or public binary release is part of this build.
