# AirDrop for Brave

An experimental macOS extension and native helper for sharing a page, link or
selected text from Brave through Apple's AirDrop interface. No account, backend
or telemetry. This independent project is not affiliated with Apple or Brave.

## Local installation

Requires Brave, macOS 14+, Xcode Command Line Tools (`xcode-select --install`)
and Node.js 24+. Apple Silicon is the initial target.

1. Run `npm ci --ignore-scripts && npm run build`.
2. Open `brave://extensions`, enable Developer mode and choose **Load unpacked**.
   Select the project's `dist` directory.
3. Copy its displayed extension ID. Run
   `scripts/install-local.sh <extension-id>`, then `scripts/doctor.sh`.
4. Pin the extension. On an HTTP or HTTPS page, click its toolbar button or
   choose **Share via AirDrop** from the page context menu. The link and text
   context menus share the clicked link or selected text respectively. Choose
   the recipient in the macOS interface. If the badge shows **!**, hover over
   the toolbar icon to see the error.

To uninstall, close any picker, run `scripts/uninstall-local.sh`, and remove the
extension in Brave. To change the ID or update the local helper, uninstall and
reinstall the helper. The installer refuses to overwrite existing files.

Run `npm test` on macOS for the TypeScript build, isolated install/uninstall and
native protocol checks. Read the [test plan](docs/testing.md) before relying on
AirDrop, the [architecture and trust model](docs/architecture.md) for design
details, and the [publishing plan](docs/publishing.md) for distribution.
