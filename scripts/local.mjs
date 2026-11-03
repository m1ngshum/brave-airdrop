import {spawnSync} from "node:child_process";
import * as fs from "node:fs";
import {homedir} from "node:os";
import path from "node:path";
import {randomUUID} from "node:crypto";

const host = "app.braveairdrop.host";
const segments = ["Library", "Application Support", "BraveSoftware", "Brave-Browser", "NativeMessagingHosts"];
const chromeSegments = ["Library", "Application Support", "Google", "Chrome", "NativeMessagingHosts"];
const folder = path.join(homedir(), ...segments);
const chromeManifest = path.join(homedir(), ...chromeSegments, host + ".json");
const manifest = path.join(folder, host + ".json");
const executable = path.join(folder, host);
const originPattern = /^chrome-extension:\/\/[a-p]{32}\/$/;
const root = path.resolve(import.meta.dirname, "..");
const command = process.argv[2];

function safe(file, directory = false) {
  const info = fs.lstatSync(file);
  if (!(directory ? info.isDirectory() : info.isFile()) ||
      info.uid !== process.getuid() || (info.mode & 0o022)) {
    throw Error("Unsafe owner, type or permissions: " + file);
  }
}
function registration(file) {
  safe(file);
  const config = JSON.parse(fs.readFileSync(file, "utf8"));
  if (config.name !== host || config.path !== executable || config.type !== "stdio" ||
      config.allowed_origins?.length !== 1 || !originPattern.test(config.allowed_origins[0])) {
    throw Error("Unexpected host registration; inspect it manually.");
  }
  return config.allowed_origins[0];
}
try {
  if (command === "install") {
    const id = process.argv[3];
    if (id?.length !== 32 || !/^[a-p]{32}$/.test(id)) throw Error("Usage: scripts/install-local.sh <32-character Brave extension ID>");
  }
  for (const location of [segments, chromeSegments]) {
    let parent = homedir();
    for (const segment of location) {
      parent = path.join(parent, segment);
      if (command === "install") {
        try { fs.mkdirSync(parent, {mode: 0o700}); } catch (error) {
          if (error.code !== "EEXIST") throw error;
        }
      }
      safe(parent, true);
    }
  }
  if (command === "install") {
    const stage = fs.mkdtempSync(path.join(folder, ".airdrop-"));
    try {
      const binary = path.join(stage, host);
      const json = path.join(stage, "host.json");
      const build = spawnSync("swiftc", ["macos/Protocol.swift", "macos/main.swift", "-o", binary],
        {cwd: root, env: {...process.env, MACOSX_DEPLOYMENT_TARGET: "14.0"}, stdio: "inherit"});
      if (build.status !== 0) throw Error("Swift build failed; install Xcode Command Line Tools.");
      fs.chmodSync(binary, 0o700);
      fs.writeFileSync(json, JSON.stringify({name: host, description: "AirDrop native messaging helper",
        path: executable, type: "stdio", allowed_origins: [`chrome-extension://${process.argv[3]}/`]}, null, 2),
        {mode: 0o600});
      const linked = [];
      try {
        for (const [from, to] of [[binary, executable], [json, manifest], [json, chromeManifest]]) {
          fs.linkSync(from, to);
          linked.push(to);
        }
      } catch (error) {
        for (const file of linked.reverse()) fs.unlinkSync(file);
        throw error;
      }
      console.log("Installed. Run scripts/doctor.sh, then try the toolbar action in Brave.");
    } finally {
      fs.rmSync(stage, {recursive: true, force: true});
    }
  } else if (command === "uninstall") {
    if (registration(manifest) !== registration(chromeManifest)) throw Error("Host registrations disagree.");
    safe(executable);
    fs.unlinkSync(chromeManifest);
    fs.unlinkSync(manifest);
    fs.unlinkSync(executable);
    console.log("Removed the native helper. Remove the extension separately in Brave.");
  } else if (command === "doctor") {
    const origin = registration(manifest);
    if (origin !== registration(chromeManifest)) throw Error("Host registrations disagree.");
    safe(executable);
    fs.accessSync(executable, fs.constants.X_OK);
    const requestId = randomUUID();
    const data = Buffer.from(JSON.stringify({version: 1, requestId, action: "ping"}));
    const header = Buffer.alloc(4);
    header.writeUInt32LE(data.length);
    const result = spawnSync(executable, [origin], {input: Buffer.concat([header, data]), timeout: 5000});
    const reply = result.stdout;
    if (result.status !== 0 || reply.length < 4 || reply.readUInt32LE() !== reply.length - 4) {
      throw Error("Native protocol ping failed.");
    }
    const response = JSON.parse(reply.subarray(4));
    if (response.version !== 1 || response.requestId !== requestId || response.status !== "ready") {
      throw Error("Unexpected native ping response.");
    }
    console.log("Native protocol ready for extension " + origin.slice(19, -1) + ". Compare with brave://extensions.");
  } else {
    throw Error("Unknown command.");
  }
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
