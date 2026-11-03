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
printf '%s' 'existing registration' >"$chrome"
if scripts/install-local.sh "$id" >"$fixture/collision.log" 2>&1; then
  echo "Installer unexpectedly replaced a Chrome registration" >&2
  exit 1
fi
test "$(cat "$chrome")" = 'existing registration'
test ! -e "$brave" && test ! -e "$brave.json"
