# Neovim Configuration

This directory contains the user configuration for Neovim. Its default location is `~/.config/nvim`.

The configuration is written in Lua and follows Neovim's runtime directory conventions.

## Directory layout

```text
~/.config/nvim/
├── init.lua                  # Configuration entry point
├── lua/                      # Lua modules loaded with require()
│   └── config/               # General configuration modules
│       ├── options.lua       # Editor options
│       ├── keymaps.lua       # Global keymaps
│       └── commands.lua      # Global user commands
├── after/                    # Loaded after the default runtime files
│   └── ftplugin/             # Filetype-specific configuration
│       ├── cpp.lua
│       ├── markdown.lua
│       ├── python.lua
│       └── vim.lua
├── autoload/                 # Vimscript autoload functions
├── compiler/                 # Compiler definitions for :compiler
├── doc/                      # Help documentation for :help
├── ftplugin/                 # Filetype plugin configuration
├── indent/                   # Filetype-specific indentation scripts
├── keymap/                   # Custom keyboard layouts
├── menu/                     # GUI menu definitions
├── pack/                     # Native package plugins
├── parser/                   # Tree-sitter parser files
├── plugin/                   # Scripts loaded automatically at startup
├── queries/                  # Tree-sitter query files
├── rplugin/                  # Remote plugin files
├── spell/                    # Spell-checking dictionaries and rules
├── syntax/                   # Syntax highlighting files
└── tutor/                    # Tutor tutorial resources
```

The empty runtime directories are intentionally present. Files should be added only when the corresponding feature is needed.

## Configuration loading

Neovim starts by loading `init.lua`. The entry point loads the general configuration modules:

```lua
require('config.options')
require('config.keymaps')
require('config.commands')
```

Lua modules live under `lua/`. The directory path maps to the module name. For example:

```lua
require('config.options')
```

loads:

```text
lua/config/options.lua
```

Filetype configuration is loaded when a matching filetype is detected. The `after/ftplugin/` directory is loaded after Neovim's default filetype configuration, making it suitable for extending or overriding default behavior.

## Current configuration modules

### `lua/config/options.lua`

Defines global editor options, including line numbers, search behavior, case sensitivity, mouse support, clipboard integration, backup and swap-file behavior, undo files, the file search path, and the default color scheme.

Undo files are stored in Neovim's state directory and no longer depend on the old `~/.vim` configuration.

### `lua/config/keymaps.lua`

Defines global keymaps. The current mapping is:

- In Insert mode, `jk` exits to Normal mode.

### `lua/config/commands.lua`

Defines global user commands. The current command is:

- `:MakeTags` recursively runs `ctags -R .` in the current directory.

### `after/ftplugin/cpp.lua`

Applies only to C++ buffers:

- Uses a two-space indentation width.
- Does not expand tabs.
- `<F5>` compiles `sol.cpp`.
- `<F6>` runs `./sol`.
- `:CpCompile` compiles with `g++` using C++23.
- `:CpRun` runs the compiled program.
- `:CP [name.cpp]` creates a C++ contest template.

### Other `after/ftplugin/*.lua` files

- `markdown.lua`: four-space indentation with spaces.
- `python.lua`: four-space indentation with spaces.
- `vim.lua`: two-space indentation with spaces.

## Runtime directory reference

These are standard runtime directories supported by Neovim. Most are currently empty, but each is available for future configuration or plugin files.

| Directory | Purpose |
| --- | --- |
| `after/` | Overrides or extends files loaded earlier in the runtime path |
| `autoload/` | On-demand Vimscript functions |
| `compiler/` | Compiler definitions selected with `:compiler` |
| `doc/` | Help documentation accessed with `:help` |
| `ftplugin/` | Filetype-specific plugin configuration |
| `indent/` | Filetype-specific indentation rules |
| `keymap/` | Custom keyboard layouts |
| `menu/` | GUI menu definitions |
| `pack/` | Native package and plugin directories |
| `parser/` | Tree-sitter parser files |
| `plugin/` | Lua or Vimscript files sourced automatically at startup |
| `queries/` | Tree-sitter highlighting, injection, and folding queries |
| `rplugin/` | Remote plugin registration files |
| `spell/` | Spell-checking dictionaries and rules |
| `syntax/` | Syntax highlighting definitions |
| `tutor/` | Tutor tutorial resources |

## Adding new configuration

Put general options in `lua/config/options.lua`, global keymaps in `lua/config/keymaps.lua`, and global commands in `lua/config/commands.lua`.

Put filetype-specific settings in `after/ftplugin/<filetype>.lua`, for example:

```text
after/ftplugin/javascript.lua
```

Put standalone Lua plugins that should run automatically at startup in `plugin/`. Put reusable functionality that should be loaded on demand in `lua/`, then load it with `require()`.
