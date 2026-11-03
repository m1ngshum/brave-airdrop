#!/bin/sh
set -eu
exec node "$(dirname "$0")/local.mjs" uninstall "$@"
