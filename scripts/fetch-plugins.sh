#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DEST="$ROOT/pack/vendor/opt"
mkdir -p "$DEST"

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to fetch plugins" >&2
  exit 1
fi

fetch_plugin() {
  name=$1
  url=$2
  branch=$3
  dir="$DEST/$name"

  if [ -d "$dir/.git" ]; then
    echo "Updating $name"
    git -C "$dir" fetch --depth 1 origin "$branch"
    git -C "$dir" checkout -q FETCH_HEAD
  elif [ -e "$dir" ]; then
    echo "$dir exists but is not a git checkout; leaving it unchanged"
  else
    echo "Fetching $name"
    git clone --depth 1 --branch "$branch" "$url" "$dir"
  fi
}

fetch_plugin "mini.pick" "https://github.com/nvim-mini/mini.pick.git" "stable"
fetch_plugin "lualine.nvim" "https://github.com/nvim-lualine/lualine.nvim.git" "master"
fetch_plugin "nvim-lint" "https://github.com/mfussenegger/nvim-lint.git" "master"

# Mason is used only by scripts/fetch-toolchain.sh on the online builder.
# The runtime config never loads it or performs automatic installation.
fetch_plugin "mason.nvim" "https://github.com/mason-org/mason.nvim.git" "main"

printf '\nInstalled plugins in: %s\n' "$DEST"
echo "Run :PortableHealth inside Neovim to verify the setup."
