# Architecture and trust model

The MV3 worker listens for the toolbar and three context-menu actions. It uses
`activeTab`, `contextMenus` and `nativeMessaging`. There are no host permissions,
content scripts, external message handlers, or network calls. It sends one
request over a Chrome native messaging port. A Swift executable uses AppKit's
public `NSSharingService.Name.sendViaAirDrop` on the main thread. Holding a port
keeps the native process alive for the delegate's terminal reply, unlike a
one-response call. Browser disconnect terminates the helper. The extension closes the port if
macOS has not reported an outcome within five minutes. A nonblocking
advisory lock on the registration prevents simultaneous picker attempts.

This is the single-process M0 candidate. AppKit's ability to present the picker
reliably from a browser-launched process is an acceptance gate. If it fails on
a real Mac, reproduce and document the failure before adding a companion app
and authenticated local IPC.

Protocol 1 uses a four-byte little-endian length and UTF-8 JSON. The request has
a UUID, `share` action, kind and matching one-field payload. The diagnostic
`ping` request opens no UI. The host rejects oversized frames, unsupported
schemes, credential-bearing URLs and all caller-supplied file requests. If
AppKit rejects plain text, the helper supplies a generated UTF-8 text file from
a private temporary directory. It removes the directory on completion, failure,
cancellation or orderly disconnect. Limits are 128 KiB
framed input, 8 KiB per URL and 16 KiB per text selection, measured in UTF-8
bytes. The port first gets `accepted` when the host is about to invoke AppKit.
Only the AppKit delegate can return `shared`, `cancelled` or a terminal share
error. `shared` is an OS callback; the project does not independently inspect
the recipient device. No payload is written to logs or included in errors.

The installer registers the same exact extension origin in the per-user Brave
and Chrome native host directories. [Current Brave source](https://github.com/brave/brave-core/blob/master/app/brave_main_delegate.cc)
uses Chrome’s location on macOS; the Brave registration covers builds using
their own data directory. Both point at the same helper. The helper checks the
caller argument against the registration beside its executable. This protects the browser
boundary and does not authenticate other processes running as the same macOS
user: they can invoke the executable with a forged argument or modify that
user's installation. The helper has no elevated permissions and never
downloads content or reads user-supplied file paths.
