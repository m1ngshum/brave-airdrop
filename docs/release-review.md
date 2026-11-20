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

## Reviewer setup

1. On macOS 14 or later, install Brave, Node.js 26 LTS, and Xcode Command Line
   Tools (`xcode-select --install`). Check out the exact helper source revision
   linked in the store test instructions.
2. Install the review copy of the extension. In `brave://extensions`, confirm
   the displayed ID. For the store item, run:

   ```sh
   scripts/install-local.sh blbeidgcnkmmlcmgafgpgoaaabnnokga
   scripts/doctor.sh
   ```

   For an unpacked build, follow the [local installation steps](../README.md#local-installation)
   and pass its displayed ID. If the helper is already installed for another ID,
   remove it with `scripts/uninstall-local.sh` before installing for review.
3. Open `https://example.com/` and click the toolbar button. Cancel the native
   picker, then reopen it and send the page to a nearby unlocked iPhone.
   Right-click the page, its IANA hyperlink, and selected text to test
   the three context-menu actions. Confirm the corresponding URL or text on
   the phone. The text may arrive as `AirDrop Selection.txt`.
4. Close any open picker and run `scripts/uninstall-local.sh`. Remove the
   extension in Brave.

## Submission checklist

Build the candidate ZIP using the [publishing instructions](publishing.md).
Review it and its SHA-256 checksum together. The ZIP contains the browser
extension only.

Before submitting to the store:

- Prepare listing icons, screenshots, and the public privacy-policy URL.
- Verify the assigned store extension ID with the native helper.
- Test the build-from-source helper on a clean Mac with Gatekeeper enabled.
  Verify the minimum supported macOS version.
- Provide a public link to the verified helper source revision and these setup
  steps to store reviewers.

No store submission or public binary release is implied by this review.
