#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT_DIR=${1:-$(dirname "$ROOT")}

"$ROOT/scripts/fetch-toolchain.sh"
"$ROOT/scripts/make-offline-bundle.sh" "$OUT_DIR"
