const host = "app.braveairdrop.host";
let busy = false;

function feedback(message: string) {
  void chrome.action.setTitle({title: message});
  void chrome.action.setBadgeText({text: "!"});
}

function share(kind: "url" | "text", value?: string) {
  if (busy) return;
  if (!value || new TextEncoder().encode(value).length > (kind === "url" ? 8192 : 16384)) {
    feedback("AirDrop: content is missing or too long");
    return;
  }
  if (kind === "url") {
    try {
      const url = new URL(value);
      if (!["https:", "http:"].includes(url.protocol) || url.username || url.password) throw Error();
      value = url.href;
    } catch {
      feedback("AirDrop: only HTTP and HTTPS links without credentials are supported");
      return;
    }
  }
  if (kind === "url" && new TextEncoder().encode(value).length > 8192) {
    feedback("AirDrop: this link is too long after URL encoding");
    return;
  }
  busy = true;
  void chrome.action.setBadgeText({text: ""});
  void chrome.action.setTitle({title: "AirDrop current page"});
  const requestId = crypto.randomUUID();
  let port: chrome.runtime.Port;
  try {
    port = chrome.runtime.connectNative(host);
  } catch {
    busy = false;
    feedback("AirDrop: cannot connect to the macOS helper");
    return;
  }
  // shortcut: if AppKit never calls back, release the picker after five minutes.
  const timeout = setTimeout(() => {
    busy = false;
    port.disconnect();
    feedback("AirDrop: timed out waiting for macOS");
  }, 300_000);
  port.onDisconnect.addListener(() => {
    clearTimeout(timeout);
    const failed = chrome.runtime.lastError;
    busy = false;
    feedback(failed ? "AirDrop: check the helper installation and extension ID" : "AirDrop: helper closed unexpectedly");
  });
  const errors: Record<string, string> = {
    AIRDROP_UNAVAILABLE: "AirDrop is unavailable for this item",
    INVALID_REQUEST: "The helper rejected this content",
    BUSY: "Another AirDrop picker is open",
    SHARE_FAILED: "macOS could not share this item"
  };
  port.onMessage.addListener((reply: unknown) => {
    if (!reply || typeof reply !== "object") return;
    const response = reply as {version?: number; requestId?: string; status?: string; error?: {code?: string}};
    if (response.version !== 1 || response.requestId !== requestId) return;
    if (response.status === "accepted") return;
    clearTimeout(timeout);
    busy = false;
    port.disconnect();
    if (response.status !== "shared" && response.status !== "cancelled") {
      const code = response.error?.code ?? "";
      feedback("AirDrop: " + (Object.hasOwn(errors, code) ? errors[code] : "unexpected helper response"));
    }
  });
  try {
    port.postMessage({version: 1, requestId, action: "share", kind, payload: {[kind]: value}});
  } catch {
    clearTimeout(timeout);
    busy = false;
    port.disconnect();
    feedback("AirDrop: cannot send a request to the helper");
  }
}

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({id: "page", title: "Share via AirDrop", contexts: ["page"]});
  chrome.contextMenus.create({id: "link", title: "AirDrop Link", contexts: ["link"]});
  chrome.contextMenus.create({id: "selection", title: "AirDrop Selection", contexts: ["selection"]});
});
chrome.action.onClicked.addListener(tab => share("url", tab.url));
chrome.contextMenus.onClicked.addListener(info => {
  switch (info.menuItemId) {
    case "page": share("url", info.pageUrl); break;
    case "link": share("url", info.linkUrl); break;
    case "selection": share("text", info.selectionText); break;
  }
});
