# Privacy

When you explicitly choose a sharing action, the extension reads the current
page URL, clicked link URL or selected text and passes it to a local macOS
helper. The helper gives it to Apple's AirDrop service so you can choose a
recipient. The recipient you select receives the item through AirDrop. Shared
URLs and text can contain private information, including query parameters.

If macOS does not accept plain text, the helper writes the selection to a
private temporary UTF-8 file for the transfer and removes it when the request
ends normally. A forced termination may leave the file in the macOS temporary
directory. The extension and helper do not send content to our servers, use
analytics or advertising, or access browser cookies or download history.
The local native host registration stores the extension ID and helper path.
macOS and the recipient handle the resulting AirDrop transfer.

Our use of information received from Google APIs adheres to the Chrome Web
Store User Data Policy, including the Limited Use requirements.
