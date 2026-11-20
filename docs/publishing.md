# Publishing plan

1. Review the [0.1.0 release checklist](release-review.md) and pass the
   remaining [physical device checks](testing.md) before submission.
2. From the repository root, build a fresh extension ZIP and checksum.
   Review the ZIP contents. The manifest must be at the archive root.

   ```sh
   (
     set -eu
     npm ci --ignore-scripts
     npm run build
     mkdir -p .build
     staging=$(mktemp -d "$PWD/.build/store-zip.XXXXXX")
     trap 'rm -rf "$staging"' EXIT
     (cd dist && zip -X "$staging/airdrop-extension.zip" manifest.json background.js)
     mv "$staging/airdrop-extension.zip" .build/airdrop-extension.zip
     (cd .build && shasum -a 256 airdrop-extension.zip > airdrop-extension.zip.sha256)
   )
   ```

3. Use the existing 0.1.0 item in the [Chrome Web Store Developer Dashboard](https://developer.chrome.com/docs/webstore/publish).
   Confirm that its extension ID is `blbeidgcnkmmlcmgafgpgoaaabnnokga`.
   Prepare the icon, screenshot, public [privacy policy](privacy.md), permission
   justifications, and reviewer instructions before requesting public review.
4. Give reviewers a public link to the exact reviewed helper source revision
   and the [setup and test steps](release-review.md#reviewer-setup).
   Test that source against the actual store ID and packaged extension on a
   clean Mac with Gatekeeper enabled.

The Chrome Web Store installs the browser extension. Users build and register
the macOS helper separately with Xcode Command Line Tools. Public distribution
is the planned visibility for 0.1.0.

## Terms and submission checks

The review name is **Local Share Bridge**. Use AirDrop and Brave only to
describe the feature and browser compatibility, and use original icons and
artwork. Avoid marks in the store title, installer name and release branding.
[Apple's trademark guidelines](https://www.apple.com/legal/intellectual-property/guidelinesfor3rdparties.html)
restrict use in product names; the [Brave Terms of Use](https://brave.com/terms-of-use/)
do not grant rights to Brave's marks. Use the attribution and independent-project
notice in the README. Check the final name and artwork before submitting.

The helper uses the documented [AppKit sharing service](https://developer.apple.com/documentation/appkit/nssharingservice),
lets the user select a recipient, and ships no Apple or Brave binaries. No
published restriction on this API use was identified in the
[Apple Developer Program terms](https://developer.apple.com/support/terms/apple-developer-program-license-agreement/).
Review the applicable signing agreement if a later release distributes binaries.

For the [Chrome Web Store policies](https://developer.chrome.com/docs/webstore/program-policies/policies)
and [developer agreement](https://developer.chrome.com/docs/webstore/program-policies/terms):

- Describe one purpose: user-initiated sharing of a page, link, or text through
  the macOS AirDrop feature. Disclose the separate macOS helper and system
  requirements prominently before installation; do not download or install it
  automatically. Include permissions, data use, the temporary text-file fallback,
  and the public privacy-policy URL in the store submission.
- Provide the exact helper source revision, installation and removal steps, and
  a test procedure. Check the store ID with the packaged extension in Brave on
  macOS. Verify each additional browser before claiming compatibility.
- Use the [Distribution tab](https://developer.chrome.com/docs/webstore/cws-dashboard-distribution)
  to set public visibility and the [Test instructions tab](https://developer.chrome.com/docs/webstore/publish)
  to explain how reviewers can build and test the helper.

If a prebuilt helper is distributed in a later release, sign it with Developer
ID Application, sign any distributed installer package with Developer ID
Installer, and [notarize and staple the package](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution).
Use a per-user setup step for native messaging registrations and test
installation, update, and removal with Gatekeeper enabled.
