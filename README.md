# nvim config — personal Neovim configuration

## What this is
Personal Neovim config for `~/.config/nvim`: a small Lua entry point, manual
package management (no plugin manager), and vendored colorschemes/plugins.

## Current status (as of 2026-11-11)
| Item | State | Source |
|---|---|---|
| Entry point | `init.lua` loads `config.options/keymaps/commands`, sets `colorscheme kanagawa` | `init.lua:2-12` |
| Theme | kanagawa (vendored 2026-11-11, replaced gruvbox) | commit `b22b98b` |
| Plugin | tuna.nvim vendored under `pack/plugins/start/` | commit `38616d0` |
| Plugin manager | none — native `pack/*/start/` loading only | `init.lua`, `git ls-files pack` (175 files) |

## How it works
`init.lua` requires `lua/config/{options,keymaps,commands}.lua` and applies
the colorscheme last, overriding `options.lua`'s `colorscheme default`
fallback.

## Map of this directory
| Path | What it is |
|---|---|
| `init.lua` | Entry point — startup wiring only |
| `lua/config/` | options, keymaps, commands modules |
| `pack/plugins/start/` | Vendored plugins (tuna.nvim), manually updated |
| `pack/themes/start/` | Vendored colorschemes (kanagawa.nvim) |
| `after/` + empty runtime dirs | ftplugin overrides; other standard runtime dirs intentionally present, mostly empty |
| `docs/`, `work/` | Project-space docs layer — describes, never edits live files |

## Conventions
- Docs describe; live files own. Docs work never edits config/runtime files.
- Decisions: ADR-style, append-only, in `docs/decisions.md`.
- Task records: `work/<date>-<slug>/RECORD.md`, append-only.
- Themes/plugins are vendored as plain files; nested `.git` removed before commit.
- Git: stage explicit paths only, never `git add -A`; no push without approval.
- Every claim cites a source file/commit or is marked unverified.
