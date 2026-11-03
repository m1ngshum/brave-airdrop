# Testing

`npm test` builds the extension and runs the installer and Swift host in a
temporary home. It covers exact origin matching, diagnostic framing, malformed
and oversized frames, unsupported requests, install permissions, refusing to
overwrite an existing registration, and uninstall. This is not an AirDrop test.

On macOS 27.2 with Brave 156.1.98.63, an isolated headless profile loaded the
MV3 extension, completed a real browser-to-helper ping, and got an `accepted`
reply for a synthetic HTTPS URL. The temporary registration was removed. The
probe did not inspect the picker or select a recipient.

## Physical-device test: November 3, 2026

Unpacked 0.1.0, source commit `15c21be`, in the active Brave profile on
macOS 27.2 with Brave 156.1.98.63. The helper diagnostic passed. The user
confirmed receipt on a nearby iPhone for the successful transfers.

| Action | Result |
| --- | --- |
| Toolbar: open picker, then Cancel | Picker appeared and closed without sending. |
| Toolbar: reopen and send | iPhone received `https://example.com/`. |
| Right-click page: Share via AirDrop | iPhone received `https://example.com/`. |
| Right-click hyperlink: AirDrop Link | iPhone received the IANA link target (`https://www.iana.org/help/example-domains`), rather than the page URL. |
| Right-click selected paragraph: AirDrop Selection | **Failed.** Brave showed “AirDrop is unavailable for this item”; no picker appeared and the iPhone received nothing. |

The helper emits this error if AppKit does not provide an AirDrop service or
the service cannot handle the supplied item. The same session successfully
shared URLs, but this test did not distinguish the two native error branches.
See Apple's [item availability check](https://developer.apple.com/documentation/appkit/nssharingservice/canperform%28withitems%3A%29).

After installing the updated helper in the same profile, **AirDrop Selection
passed**. The iPhone received `AirDrop Selection.txt` and the user confirmed it
contained the exact selected Unicode text, `许可`. The original plain-text
failure above is retained as the reproduction. The local staging test checks
byte-for-byte Unicode, newline, and emoji preservation and private permissions.

Still pending: a clean-profile install, Brave
restart, simultaneous requests, missing-helper and unavailable-AirDrop
feedback, and a macOS 14 run. Images and downloaded files are deferred.
