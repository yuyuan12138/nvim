#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PARENT=$(dirname "$ROOT")
NAME=$(basename "$ROOT")

if [ ! -d "$ROOT/pack/vendor/opt/mini.pick" ] || \
   [ ! -d "$ROOT/pack/vendor/opt/lualine.nvim" ] || \
   [ ! -d "$ROOT/pack/vendor/opt/nvim-lint" ]; then
  echo "Runtime plugins are missing." >&2
  echo "Run scripts/fetch-plugins.sh first." >&2
  exit 1
fi

if [ ! -x "$ROOT/tools/node/bin/node" ] || \
   [ ! -x "$ROOT/tools/go/bin/go" ] || \
   [ ! -x "$ROOT/tools/ruff/bin/ruff" ] || \
   [ ! -d "$ROOT/tools/mason/bin" ]; then
  echo "The bundled toolchain is missing." >&2
  echo "Run scripts/fetch-toolchain.sh on an online machine first." >&2
  exit 1
fi

OS=$(uname -s)
ARCH=$(uname -m)
case "$OS/$ARCH" in
  Linux/x86_64|Linux/amd64) TAG="linux-x86_64" ;;
  Linux/aarch64|Linux/arm64) TAG="linux-arm64" ;;
  Darwin/arm64) TAG="macos-arm64" ;;
  Darwin/x86_64) TAG="macos-x86_64" ;;
  *) TAG=$(printf '%s-%s' "$OS" "$ARCH" | tr '[:upper:]' '[:lower:]') ;;
esac

OUT_DIR=${1:-$PARENT}
mkdir -p "$OUT_DIR"
TAR_OUTPUT="$OUT_DIR/nvim-portable-$TAG-offline.tar.gz"
ZIP_OUTPUT="$OUT_DIR/nvim-portable-$TAG-offline.zip"

STAGE=$(mktemp -d "${TMPDIR:-/tmp}/portable-nvim.XXXXXX")
trap 'rm -rf "$STAGE"' EXIT HUP INT TERM

mkdir -p "$STAGE/$NAME"
(
  cd "$ROOT"
  tar -cf - \
    --exclude='./.git' \
    --exclude='*/.git' \
    --exclude='./pack/vendor/opt/mason.nvim' \
    --exclude='./tools/mason/staging' \
    .
) | tar -xf - -C "$STAGE/$NAME"

cat >> "$STAGE/$NAME/tools/BUILD-INFO.txt" <<INFO
archive_platform=$TAG
archive_created=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
INFO

rm -f "$TAR_OUTPUT" "$ZIP_OUTPUT"
tar -czf "$TAR_OUTPUT" -C "$STAGE" "$NAME"

if command -v zip >/dev/null 2>&1; then
  (
    cd "$STAGE"
    # -y stores symbolic links instead of dereferencing them. This matters for
    # Mason's bin directory. Extract with a Unix unzip implementation.
    zip -qry -y "$ZIP_OUTPUT" "$NAME"
  )
else
  echo "zip is unavailable; only the tar.gz archive was created." >&2
fi

printf 'Created: %s\n' "$TAR_OUTPUT"
if [ -f "$ZIP_OUTPUT" ]; then
  printf 'Created: %s\n' "$ZIP_OUTPUT"
fi

echo "Install with:"
echo "  mkdir -p ~/.config/nvim"
echo "  tar -xzf $(basename "$TAR_OUTPUT") -C ~/.config/nvim --strip-components=1"
