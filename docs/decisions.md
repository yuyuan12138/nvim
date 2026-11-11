# Decision log (ADR-style)

Format: Context → Decision → Consequence. Append-only; newest at the bottom.
Live files own the behavior — nothing here is re-litigated in docs work.

---

## ADR-001 — Manual pack management over a plugin manager
**Date**: 2026-10-28 (recorded 2026-11-11, retrofit) · **Source**: commits `798f6d2`, `38616d0`; `git ls-files pack` (175 tracked files)
- **Context**: Only a handful of plugins/themes are needed; a plugin manager would add startup and maintenance overhead for that scale.
- **Decision**: Vendor plugins as plain trees under `pack/plugins/start/` and rely on Neovim's native `packpath` startup loading. No plugin manager appears in `init.lua` or `lua/config/` (verified by grep, 2026-11-11).
- **Consequence**: Updates are manual (copy in a tree); in exchange, startup has zero external dependencies.

## ADR-002 — Kanagawa over gruvbox (user ruling)
**Date**: 2026-11-11 · **Source**: commit `b22b98b`; `init.lua:12`
- **Context**: gruvbox had been vendored (commit `f6826fd`, 2026-10-28); user ruled to switch themes.
- **Decision**: Remove `pack/themes/start/gruvbox/`, vendor `kanagawa.nvim` under `pack/themes/start/`, and set `vim.cmd.colorscheme("kanagawa")` in `init.lua`.
- **Consequence**: `options.lua` still ends with `colorscheme default` as fallback; kanagawa is the effective theme because `init.lua` applies it last.

## ADR-003 — Vendoring convention: plain files, nested .git removed
**Date**: 2026-11-11 · **Source**: commit `b22b98b`; `ls pack/{themes,plugins}/start/*/` — no `.git` present in either vendored tree
- **Context**: Vendored upstream repos with their own `.git` would become nested repositories/gitlinks, breaking plain-file tracking in this repo.
- **Decision**: Vendor every theme/plugin as plain files with its nested `.git` directory removed before commit, tracked directly by this repo.
- **Consequence**: Upstream history is not preserved; updates replace the tree wholesale and must re-check that no `.git` gets staged.
