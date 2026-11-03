#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
./node_modules/.bin/tsc --strict --target ES2022 --types chrome --outDir dist extension/src/background.ts
cp extension/manifest.json dist/
