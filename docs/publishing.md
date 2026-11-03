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
Review the agreement applicable to the signing account before distribution.

For the [Chrome Web Store policies](https://developer.chrome.com/docs/webstore/program-policies/policies)
and [developer agreement](https://developer.chrome.com/docs/webstore/program-policies/terms):

- Describe one purpose: user-initiated sharing of a page, link, or text through
  the macOS AirDrop feature. Disclose the separate macOS helper and system
  requirements prominently before installation; do not download or install it
  automatically. Include permissions, data use, the temporary text-file fallback,
  and the public privacy-policy URL in the store submission.
- Provide reviewers with the signed helper, installation and removal steps,
  and a test procedure. Check the exact store ID with the packaged helper on
  current Chrome and Brave on macOS before making compatibility claims.
- Start with [private trusted testers](https://developer.chrome.com/docs/webstore/cws-dashboard-distribution)
  and then request public distribution. Private and unlisted items still
  undergo review. Approval is up to the store and is not guaranteed.

Use a per-user setup step for the native messaging registrations. A package
running as root must not guess the target home or place writable registrations
in other users' profiles. Test installation, update, and removal without
disabling Gatekeeper.
