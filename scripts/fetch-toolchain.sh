#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TOOLS="$ROOT/tools"
NODE_DIR="$TOOLS/node"
GO_DIR="$TOOLS/go"
MASON_DIR="$TOOLS/mason"
RUFF_DIR="$TOOLS/ruff"
NODE_VERSION=24.18.0
GO_VERSION=1.25.12
RUFF_VERSION=0.15.22

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "$1 is required on the online builder" >&2
    exit 1
  fi
}

need nvim
need git
need curl
need tar
need unzip

OS=$(uname -s)
ARCH=$(uname -m)

case "$OS/$ARCH" in
  Linux/x86_64|Linux/amd64)
    NODE_PLATFORM="linux-x64"
    NODE_SHA256="783130984963db7ba9cbd01089eaf2c2efb055c7c1693c943174b967b3050cb8"
    GO_PLATFORM="linux-amd64"
    GO_SHA256="234828b7a89e0e303d2556310ee549fbcf253d28de937bac3da13d6294262ac1"
    RUFF_PLATFORM="x86_64-unknown-linux-gnu"
    RUFF_SHA256="d535a4be6504146e757eff67b992f11a293a7a108be22e2a5898b32c32565996"
    PLATFORM_TAG="linux-x86_64"
    ;;
  Linux/aarch64|Linux/arm64)
    NODE_PLATFORM="linux-arm64"
    NODE_SHA256="6b4484c2190274175df9aa8f28e2d758a819cb1c1fe6ab481e2f95b463ab8508"
    GO_PLATFORM="linux-arm64"
    GO_SHA256="8b5884aef89600aef5b0b051fb971f11f49bb996521e911f30f02a66884f7bd2"
    RUFF_PLATFORM="aarch64-unknown-linux-gnu"
    RUFF_SHA256="54ec426d839d7cea1096e9ea1c5486fd2f3df62ee6cfd71dc090b18f99bebd90"
    PLATFORM_TAG="linux-arm64"
    ;;
  Darwin/arm64)
    NODE_PLATFORM="darwin-arm64"
    NODE_SHA256="e1a97e14c99c803e96c7339403282ea05a499c32f8d83defe9ef5ec66f979ed1"
    GO_PLATFORM="darwin-arm64"
    GO_SHA256="fa2c88bbcf64bd3b2aef355f026cfec6d3a4a01c132f999c8f8c964eb767164f"
    RUFF_PLATFORM="aarch64-apple-darwin"
    RUFF_SHA256="a2881af26fd1d19f4932c4ddf1e70b4e0efcf48513c5dae082564e03f0b467a3"
    PLATFORM_TAG="macos-arm64"
    ;;
  Darwin/x86_64)
    NODE_PLATFORM="darwin-x64"
    NODE_SHA256="dfd0dbd3e721503434df7b7205e719f61b3a3a31b2bcf9729b8b91fea240f080"
    GO_PLATFORM="darwin-amd64"
    GO_SHA256="00a2e743b82bccec03c51c4b0f7e46d5fec52184075fd6c5183c3bb39ae9fb00"
    RUFF_PLATFORM="x86_64-apple-darwin"
    RUFF_SHA256="687a9ceb88ab85dab061026d5017218225a481121b1a40862cc8f92b56f18090"
    PLATFORM_TAG="macos-x86_64"
    ;;
  *)
    echo "Unsupported builder platform: $OS/$ARCH" >&2
    echo "Supported: Linux x86_64/arm64 and macOS x86_64/arm64." >&2
    exit 1
    ;;
esac

verify_sha256() {
  file=$1
  expected=$2
  if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$file" | awk '{print $1}')
  elif command -v shasum >/dev/null 2>&1; then
    actual=$(shasum -a 256 "$file" | awk '{print $1}')
  else
    echo "sha256sum or shasum is required" >&2
    exit 1
  fi

  if [ "$actual" != "$expected" ]; then
    echo "Checksum mismatch for $file" >&2
    echo "Expected: $expected" >&2
    echo "Actual:   $actual" >&2
    exit 1
  fi
}

install_node() {
  if [ -x "$NODE_DIR/bin/node" ]; then
    existing=$($NODE_DIR/bin/node --version 2>/dev/null || true)
    if [ "$existing" = "v$NODE_VERSION" ]; then
      echo "Bundled Node already present: $existing"
      return
    fi
  fi

  tmp=$(mktemp -d "${TMPDIR:-/tmp}/portable-node.XXXXXX")
  archive="$tmp/node.tar.gz"
  url="https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-$NODE_PLATFORM.tar.gz"

  echo "Downloading Node.js v$NODE_VERSION for $PLATFORM_TAG"
  curl -fL --retry 3 --connect-timeout 20 "$url" -o "$archive"
  verify_sha256 "$archive" "$NODE_SHA256"

  rm -rf "$NODE_DIR"
  mkdir -p "$NODE_DIR"
  tar -xzf "$archive" -C "$NODE_DIR" --strip-components=1
  rm -rf "$tmp"
}

install_go() {
  if [ -x "$GO_DIR/bin/go" ]; then
    existing=$($GO_DIR/bin/go version 2>/dev/null | awk '{print $3}' || true)
    if [ "$existing" = "go$GO_VERSION" ]; then
      echo "Bundled Go already present: $existing"
      return
    fi
  fi

  tmp=$(mktemp -d "${TMPDIR:-/tmp}/portable-go.XXXXXX")
  archive="$tmp/go.tar.gz"
  url="https://go.dev/dl/go$GO_VERSION.$GO_PLATFORM.tar.gz"

  echo "Downloading Go $GO_VERSION for $PLATFORM_TAG"
  curl -fL --retry 3 --connect-timeout 20 "$url" -o "$archive"
  verify_sha256 "$archive" "$GO_SHA256"

  rm -rf "$GO_DIR"
  mkdir -p "$GO_DIR"
  tar -xzf "$archive" -C "$GO_DIR" --strip-components=1
  rm -rf "$tmp"
}

install_ruff() {
  if [ -x "$RUFF_DIR/bin/ruff" ]; then
    existing=$($RUFF_DIR/bin/ruff --version 2>/dev/null | awk '{print $2}' || true)
    if [ "$existing" = "$RUFF_VERSION" ]; then
      echo "Bundled Ruff already present: $existing"
      return
    fi
  fi

  tmp=$(mktemp -d "${TMPDIR:-/tmp}/portable-ruff.XXXXXX")
  archive="$tmp/ruff.tar.gz"
  extract_dir="$tmp/extract"
  url="https://releases.astral.sh/github/ruff/releases/download/$RUFF_VERSION/ruff-$RUFF_PLATFORM.tar.gz"

  echo "Downloading Ruff $RUFF_VERSION for $PLATFORM_TAG"
  curl -fL --retry 3 --connect-timeout 20 "$url" -o "$archive"
  verify_sha256 "$archive" "$RUFF_SHA256"

  mkdir -p "$extract_dir"
  tar -xzf "$archive" -C "$extract_dir"
  binary=$(find "$extract_dir" -type f -name ruff | head -n 1)
  if [ -z "$binary" ]; then
    echo "Ruff archive does not contain a ruff executable" >&2
    rm -rf "$tmp"
    exit 1
  fi

  rm -rf "$RUFF_DIR"
  mkdir -p "$RUFF_DIR/bin"
  cp "$binary" "$RUFF_DIR/bin/ruff"
  chmod +x "$RUFF_DIR/bin/ruff"
  rm -rf "$tmp"
}

mkdir -p "$TOOLS"
"$ROOT/scripts/fetch-plugins.sh"
install_node
install_go
install_ruff

PATH="$RUFF_DIR/bin:$GO_DIR/bin:$NODE_DIR/bin:$PATH"
export PATH
export GOROOT="$GO_DIR"
export PORTABLE_CONFIG_ROOT="$ROOT"
export PORTABLE_MASON_ROOT="$MASON_DIR"
export PORTABLE_INSTALL_SCRIPT="$ROOT/scripts/mason-install.lua"

printf '%s\n' "Installing LSP servers and linters into $MASON_DIR"
nvim --headless -u NONE \
  -c 'lua dofile(vim.env.PORTABLE_INSTALL_SCRIPT)'

cat > "$TOOLS/BUILD-INFO.txt" <<INFO
platform=$PLATFORM_TAG
built_on=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
node=$($NODE_DIR/bin/node --version)
go=$($GO_DIR/bin/go version)
ruff=$($RUFF_DIR/bin/ruff --version)
neovim_builder=$(nvim --version | sed -n '1p')
INFO

printf '\nToolchain ready in: %s\n' "$TOOLS"
printf 'Platform: %s\n' "$PLATFORM_TAG"
echo "Run scripts/make-offline-bundle.sh to create the transferable archives."
