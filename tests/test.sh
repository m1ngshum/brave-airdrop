#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
export HOME="$fixture"
id=abcdefghijklmnopabcdefghijklmnop
scripts/install-local.sh "$id"
scripts/doctor.sh
if scripts/install-local.sh "$id" >"$fixture/reinstall.log" 2>&1; then
  echo "Installer unexpectedly overwrote registration" >&2
  exit 1
fi
scripts/doctor.sh
node --test tests/native.test.mjs
scripts/uninstall-local.sh
if scripts/doctor.sh >"$fixture/doctor.log" 2>&1; then
  echo "Doctor unexpectedly passed after uninstall" >&2
  exit 1
fi

chrome="$fixture/Library/Application Support/Google/Chrome/NativeMessagingHosts/app.braveairdrop.host.json"
brave="$fixture/Library/Application Support/BraveSoftware/Brave-Browser/NativeMessagingHosts/app.braveairdrop.host"
scripts/install-local.sh "$id"
rm "$chrome"
rmdir "$(dirname "$chrome")"
scripts/uninstall-local.sh
test ! -e "$brave"
test ! -e "$brave.json"
scripts/uninstall-local.sh
scripts/install-local.sh "$id"
rm "$brave"
scripts/uninstall-local.sh
test ! -e "$brave.json"
test ! -e "$chrome"

printf '%s' 'existing registration' >"$chrome"
if scripts/install-local.sh "$id" >"$fixture/collision.log" 2>&1; then
  echo "Installer unexpectedly replaced a Chrome registration" >&2
  exit 1
fi
test "$(cat "$chrome")" = 'existing registration'
test ! -e "$brave"
test ! -e "$brave.json"

rm "$chrome"
printf '%s' 'existing executable' >"$brave"
if scripts/install-local.sh "$id" >"$fixture/binary-collision.log" 2>&1; then
  echo "Installer unexpectedly replaced a helper executable" >&2
  exit 1
fi
test "$(cat "$brave")" = 'existing executable'
test ! -e "$brave.json"
test ! -e "$chrome"
if scripts/uninstall-local.sh >"$fixture/lone-binary.log" 2>&1; then
  echo "Uninstaller unexpectedly accepted an unregistered executable" >&2
  exit 1
fi
test "$(cat "$brave")" = 'existing executable'
rm "$brave"

scripts/install-local.sh "$id"
node --input-type=module - "$chrome" <<'JS'
import {readFileSync, writeFileSync} from "node:fs";
const manifest = process.argv[2];
const config = JSON.parse(readFileSync(manifest));
config.allowed_origins = {0: config.allowed_origins[0], length: 1};
writeFileSync(manifest, JSON.stringify(config));
JS
for command in doctor uninstall-local; do
  if "scripts/$command.sh" >"$fixture/$command.log" 2>&1; then
    echo "$command unexpectedly accepted a malformed registration" >&2
    exit 1
  fi
  grep -F 'Unexpected host registration' "$fixture/$command.log"
done
test -e "$brave"
test -e "$brave.json"
test -e "$chrome"

MACOSX_DEPLOYMENT_TARGET=14.0 swiftc macos/Protocol.swift tests/SelectionTest.swift -o "$fixture/selection-test"
"$fixture/selection-test"
