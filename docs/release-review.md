# 0.1.0 release review

**Status: ready for review.** Page, hyperlink, and selected Unicode text
arrived on an iPhone. When macOS rejects plain text, the helper shares the
selection as a UTF-8 `.txt` file. Store packaging and clean-machine validation
remain pending.

The extension is designed to send the current page, a clicked link, or
selected text to a recipient chosen in macOS AirDrop. The extension requires a
separately installed macOS helper. It sends no content to a project server and
uses no analytics. See the [privacy policy](privacy.md).

| Permission | Purpose |
| --- | --- |
| `activeTab` | Read the current page URL when the user invokes the toolbar action. |
| `contextMenus` | Offer sharing actions on the page, links and selected text. |
| `nativeMessaging` | Send the item and receive status from the locally installed helper. |

Reviewers can follow the [source installation](../README.md#local-installation)
with the unpacked 0.1.0 build and check the [test record](testing.md). Use an
unlocked nearby iPhone and confirm the received item on the phone. The desktop
picker opening alone does not establish delivery.

Build the candidate ZIP using the [publishing instructions](publishing.md).
Review it and its SHA-256 checksum together. The ZIP contains the browser
extension only.

Before submitting to the store:

- Prepare listing icons, screenshots, and the public privacy-policy URL.
- Assign and verify the store extension ID with the native helper.
- Build, sign, notarize and test the installer on a clean Mac with Gatekeeper
  enabled. Verify the minimum supported macOS version.
- Provide the verified installer and setup instructions to store reviewers.

No store submission or public binary release is implied by this review.
