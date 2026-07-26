# Portable Neovim config

A small, offline-first Neovim configuration for Linux, macOS, and WSL.

It has two operating modes:

1. **Core mode** — only the Lua config is present. Neovim starts normally and uses any tools already available in `$PATH`.
2. **Full offline mode** — plugins, language servers, linters, and pinned Node.js and Go runtimes are packed into a platform-specific archive.

Neovim never downloads anything during startup.

## Included editor features

- Built-in Neovim LSP client.
- `mini.pick` fuzzy file, text, buffer, and help search.
- `lualine.nvim` statusline.
- `nvim-lint` lint-on-save integration.
- Built-in netrw file explorer and native fallbacks when plugins are absent.
- `:PortableHealth` report for plugins, LSP servers, and linters.

Recommended runtime Neovim version: **0.9 or newer**. Use a recent Neovim release on the online builder because Mason is used there only to assemble the archive.

## Language coverage

| Language or format | LSP | Linter or diagnostics |
|---|---|---|
| Lua | `lua-language-server` | `selene` |
| C / C++ / Objective-C / CUDA | `clangd` | clang-tidy checks inside `clangd` |
| Python | `pyright` | `ruff` |
| Rust | `rust-analyzer` | rust-analyzer checks; optional `cargo clippy` |
| Go | `gopls` | gopls staticcheck analysis and `staticcheck` |
| Shell | `bash-language-server` | `shellcheck` |
| JavaScript / TypeScript | `typescript-language-server` | `eslint_d` when an ESLint config exists |
| HTML | VS Code HTML server | LSP diagnostics |
| CSS / SCSS / Less | VS Code CSS server | `stylelint` when a Stylelint config exists |
| JSON / JSONC | VS Code JSON server | LSP diagnostics |
| YAML | `yaml-language-server` | LSP diagnostics; optional system `yamllint` |
| TOML | `taplo` | `taplo` |
| Markdown | `marksman` | `markdownlint-cli2` |
| Dockerfile | Dockerfile language server | `hadolint` |

The full bundle includes a pinned Go toolchain, so `gopls` and `staticcheck` work without a system Go installation. It does not include a Rust toolchain; Rust analysis is best when `cargo`, `rustc`, and Clippy are installed on the target machine.

## Install the lightweight core

```sh
mkdir -p ~/.config
cp -R nvim-portable ~/.config/nvim
```

This starts without plugins or bundled tools.

## Build a full offline archive

Build on an **online machine with the same operating system and CPU architecture** as the offline target.

Examples:

- Linux x86_64 also covers normal x86_64 WSL installations.
- Build the Apple Silicon archive on an arm64 Mac.
- Build the Intel macOS archive on an Intel Mac.

Required only on the online builder:

- Neovim
- Git
- curl
- tar
- unzip
- zip, if a ZIP output is wanted

Run:

```sh
cd nvim-portable
sh scripts/build-offline-bundle.sh
```

The script performs these steps:

1. Downloads the three runtime plugins plus build-only `mason.nvim`.
2. Downloads pinned Node.js and Go runtimes into `tools/node` and `tools/go`.
3. Uses Mason in headless Neovim to install all selected LSP servers and linters into `tools/mason`.
4. Produces platform-specific `.tar.gz` and `.zip` archives.
5. Removes build-only Mason plugin source from the final archive.

Typical output names:

```text
nvim-portable-linux-x86_64-offline.tar.gz
nvim-portable-linux-x86_64-offline.zip
nvim-portable-macos-arm64-offline.tar.gz
```

## Install on the offline machine

The tar archive is the safest choice because it reliably preserves Mason's symbolic links:

```sh
mkdir -p ~/.config/nvim
tar -xzf nvim-portable-linux-x86_64-offline.tar.gz \
  -C ~/.config/nvim --strip-components=1
```

For ZIP, extract it with a Unix `unzip` implementation that preserves symbolic links, then copy its contents to `~/.config/nvim`.

No tool installation or network access happens when Neovim starts.

## Why archives are platform-specific

Many language servers, linters, and runtimes are native executables. Linux, macOS Intel, and macOS Apple Silicon require different binaries. A single universal archive would be much larger and would still not solve old-glibc compatibility on every Linux distribution. WSL uses the matching Linux archive.

On a very old Linux host, a bundled binary can fail if its required glibc is newer than the host. In that case, either:

- build the bundle on a machine with an equally old compatible userspace;
- use older pinned tool versions;
- or keep only the core config and use system-installed tools.

## Linting behavior

Linting runs after a successful write. It is intentionally not run on every keystroke. Rust Clippy is manual-only because it can check an entire workspace; invoke it with `<Space>ll`.

| Mapping or command | Action |
|---|---|
| `<Space>ll` or `:Lint` | Lint the current buffer now |
| `<Space>lT` or `:LintToggle` | Toggle lint-on-save for the session |

Set this in `lua/local.lua` to disable lint-on-save permanently on one machine:

```lua
vim.g.portable_lint_on_save = false
```

ESLint and Stylelint are run only when a matching project configuration file exists.

## Search mappings

| Mapping | Action |
|---|---|
| `<Space>ff` | Find files |
| `<Space>fg` | Search project text |
| `<Space>fb` | Find buffers |
| `<Space>fh` | Search help |
| `<Space>fr` | Recent files |
| `<Space>e` | Built-in file explorer |

`ripgrep` and `fd` are optional. Native fallbacks remain available.

## LSP mappings

| Mapping | Action |
|---|---|
| `gd` | Definition |
| `gD` | Declaration |
| `gr` | References |
| `gi` | Implementation |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<Space>rn` | Rename |
| `<Space>ca` | Code action |
| `<Space>lf` | Format through LSP |
| `<C-Space>` | Omnifunc completion in Insert mode |
| `[d` / `]d` | Previous / next diagnostic |
| `<Space>dd` | Diagnostic details |

## Machine-specific overrides

Copy the example file:

```sh
cp lua/local.lua.example lua/local.lua
```

Keep host-specific paths and behavior there. The file is intentionally ignored by Git.

## Updating the bundle

On an online builder:

```sh
sh scripts/build-offline-bundle.sh
```

This refreshes plugins and Mason packages, then creates a new archive. The remote machine remains completely offline.


## Ruff and Python 3.14

Ruff is downloaded as an official standalone native executable. It is deliberately not installed through Mason/Python, so the build does not depend on `venv`, `pip`, or `ensurepip`.

