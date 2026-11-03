import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import {randomUUID} from "node:crypto";
import {readFileSync, statSync} from "node:fs";
import {homedir} from "node:os";
import {join} from "node:path";
import {test} from "node:test";

const host = join(homedir(), "Library/Application Support/BraveSoftware/Brave-Browser/NativeMessagingHosts/app.braveairdrop.host");
const origin = "chrome-extension://abcdefghijklmnopabcdefghijklmnop/";
const requestId = randomUUID();
const ping = {version: 1, requestId, action: "ping"};
const request = {...ping, action: "share", kind: "url", payload: {url: "https://example.com/"}};

function frame(body) {
  const data = Buffer.from(typeof body === "string" ? body : JSON.stringify(body));
  const length = Buffer.alloc(4);
  length.writeUInt32LE(data.length);
  return Buffer.concat([length, data]);
}

function invoke(input, caller = origin) {
  const {status, stdout, error} = spawnSync(host, [caller], {input, timeout: 5000});
  assert.ifError(error);
  assert.equal(status, 0);
  assert.equal(stdout.readUInt32LE(), stdout.length - 4);
  return JSON.parse(stdout.subarray(4));
}

test("installer restricts the executable and manifest to the installing user", () => {
  assert.equal(statSync(host).mode & 0o777, 0o700);
  assert.equal(statSync(host + ".json").mode & 0o777, 0o600);
  const chromeManifest = join(homedir(), "Library/Application Support/Google/Chrome/NativeMessagingHosts/app.braveairdrop.host.json");
  const braveManifest = readFileSync(host + ".json", "utf8");
  assert.deepEqual(JSON.parse(braveManifest).allowed_origins, [origin]);
  assert.equal(readFileSync(chromeManifest, "utf8"), braveManifest);
  assert.equal(statSync(chromeManifest).mode & 0o777, 0o600);
});

test("registered caller gets a correlated ping; other origins are rejected", () => {
  assert.deepEqual(invoke(frame(ping)), {version: 1, requestId, status: "ready"});
  assert.equal(invoke(frame(ping), origin.replace("abcd", "aaaa")).error.code, "UNAUTHORIZED");
});

test("invalid and truncated frames cannot invoke AppKit", () => {
  for (const input of [Buffer.alloc(3), Buffer.alloc(4), Buffer.from([1, 0, 2, 0]), frame(ping).subarray(0, -1), frame("{")]) {
    assert.equal(invoke(input).error.code, "INVALID_REQUEST");
  }
});

test("rejects unsupported protocol, content and excessive UTF-8", () => {
  for (const body of [
    {...ping, version: true}, {...ping, version: 2}, {...ping, action: "execute"},
    {...request, payload: {url: "file:///etc/passwd"}},
    {...request, payload: {url: "https://user:password@example.com"}},
    {...request, payload: {url: "https://example.com/\n"}},
    {...request, kind: "file", payload: {file: "/tmp/example"}},
    {...request, kind: "text", payload: {text: "界".repeat(6000)}},
    {...request, payload: {...request.payload, extra: "unexpected"}}
  ]) {
    assert.deepEqual(invoke(frame(body)), {version: 1, requestId, status: "error", error: {code: "INVALID_REQUEST"}});
  }
});
