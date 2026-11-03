# Testing

`npm test` builds the extension and runs the installer and Swift host in a
temporary home. It covers exact origin matching, diagnostic framing, malformed
and oversized frames, unsupported requests, install permissions, refusing to
overwrite an existing registration, and uninstall. This is not an AirDrop test.

On macOS 27.2 with Brave 156.1.98.63, an isolated headless profile loaded the
MV3 extension, completed a real browser-to-helper ping, and got an `accepted`
reply for a synthetic HTTPS URL. The temporary registration was removed. The
probe did not inspect the picker or select a recipient.

Before releasing, use an Apple Silicon Mac with a clean Brave profile and a
second discoverable Apple device. Record the macOS and Brave versions:

1. Install the unpacked build and confirm the doctor accepts the exact ID.
2. Use the toolbar and page context menu with a harmless HTTPS URL. Observe
   Apple's picker and verify the received URL on the other device.
3. Share a different hyperlink and selected Unicode text. Verify the recipient
   gets the link target and the text respectively.
4. Cancel the picker and try again. Check unavailable AirDrop and missing helper
   feedback. Repeat after restarting Brave and try simultaneous actions.
5. Repeat on macOS 14 before claiming compatibility with that minimum version.

Images and downloaded files are intentionally deferred. Do not claim the picker
or transfer works until the corresponding manual test passes.
