# Neovim Config

A minimal Neovim configuration tailored for competitive programming and general development.

## Structure

```
~/.config/nvim/
├── init.lua                       # Entry point
├── lua/
│   ├── config/
│   │   ├── basic.lua              # Editor settings & colorscheme
│   │   ├── keybindings.lua        # Keymaps & CP shortcuts
│   │   ├── lang-specific.lua      # Per-filetype settings (C/C++, Lua)
│   │   ├── plugins.lua            # Lazy.nvim bootstrap
│   │   └── template.lua           # Template system
│   └── plugin-config/
│       ├── lualine.lua            # Statusline
│       └── telescope.lua          # Fuzzy finder
├── templates/                     # Template files (.tpl)
├── template_paths.yaml            # Template search paths & suffixes
└── lazy-lock.json
```

## Plugins

| Plugin | Purpose |
|--------|---------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [telescope-fzf-native](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | FZF sorter for Telescope |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | File icons |

## Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `Space` | Normal | Leader key |
| `jk` | Insert | Escape |
| `<C-e>` | Normal | Scroll down 5 lines |
| `<` / `>` | Visual | Indent and reselect |
| `J` / `K` | Visual | Move selection down/up |
| `p` | Visual | Paste without yanking |
| `<F5>` | Normal | Compile `sol.cpp` (C++23, O2) |
| `<F2>` | Normal | Open `in` file |
| `<F6>` | Normal | Run `./sol < in` |
| `<leader>ff` | Normal | Find files (Telescope) |
| `<leader>fg` | Normal | Live grep (Telescope) |
| `<leader>fb` | Normal | Buffers (Telescope) |
| `<leader>fh` | Normal | Help tags (Telescope) |

## Template System

Templates are managed via `template.lua` and configured in `template_paths.yaml`.

### Commands

| Command | Description |
|---------|-------------|
| `:Tpl` | Pick a template interactively |
| `:Tpl <name>` | Insert template by name |
| `:TplPaths` | Print all search paths and suffixes |
| `:Acm` | Insert CP template for `sol.cpp` |

### Configuration (`template_paths.yaml`)

```yaml
paths:
  - ~/.config/nvim/templates
  - ~/cp/Wlib

suffixes:
  - .tpl
```

- **paths** — directories to search for template files (supports `~` expansion)
- **suffixes** — file extensions recognized as templates

### Template Variables

| Variable | Replaced with |
|----------|--------------|
| `{{AUTHOR}}` | `Yuyuan` |
| `{{CREATED_AT}}` | Current datetime (`YYYY-MM-DD HH:MM:SS`) |

## Editor Settings

- Colorscheme: **unokai** (with bold removed across highlight groups)
- Line numbers: relative + absolute
- Tabs: 4 spaces by default, 2 for C/C++ and Lua
- C/C++ uses hard tabs; Lua and others use spaces
- 120-column ruler
- Unix line endings
- Smart case-insensitive search
