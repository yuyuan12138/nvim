# Neovim 配置说明

本目录是 Neovim 的用户配置目录，默认位置为 `~/.config/nvim`。
配置采用 Lua，并按照 Neovim 的运行时目录约定组织。

## 目录结构

```text
~/.config/nvim/
├── init.lua                  # 配置入口
├── lua/                      # Lua 模块，可通过 require() 加载
│   └── config/               # 通用配置模块
│       ├── options.lua       # 编辑器选项
│       ├── keymaps.lua       # 全局快捷键
│       └── commands.lua      # 全局用户命令
├── after/                    # 在默认运行时配置之后加载
│   └── ftplugin/             # 文件类型专属配置
│       ├── cpp.lua
│       ├── markdown.lua
│       ├── python.lua
│       └── vim.lua
├── autoload/                 # Vimscript 自动加载脚本
├── compiler/                 # :compiler 使用的编译器配置
├── doc/                      # :help 使用的帮助文档
├── ftplugin/                 # 文件类型插件配置
├── indent/                   # 文件类型缩进脚本
├── keymap/                   # 键盘布局定义
├── menu/                     # GUI 菜单定义
├── pack/                     # 原生 packages 插件目录
├── parser/                   # Tree-sitter 解析器
├── plugin/                   # 启动时自动加载的插件脚本
├── queries/                  # Tree-sitter 查询文件
├── rplugin/                  # Remote plugin 文件
├── spell/                    # 拼写检查词典和规则
├── syntax/                   # 语法高亮文件
└── tutor/                    # Tutor 教程资源
```

空目录已经建立，后续只有真正需要对应运行时功能时才添加文件。

## 配置加载流程

Neovim 启动后首先读取 `init.lua`。入口文件只负责加载通用模块：

```lua
require('config.options')
require('config.keymaps')
require('config.commands')
```

Lua 模块放在 `lua/` 下，目录名对应 `require()` 的模块名。例如：

```lua
require('config.options')
```

对应文件：

```text
lua/config/options.lua
```

文件类型配置会在打开对应类型的文件时加载。`after/ftplugin/` 表示在 Neovim 默认的文件类型配置之后加载，适合覆盖或补充默认行为。

## 当前配置模块

### `lua/config/options.lua`

管理全局编辑器选项，包括行号、搜索行为、大小写匹配、鼠标、剪贴板、备份、交换文件、undo 文件、文件搜索路径和默认颜色方案。

Undo 文件存放在 Neovim 的 state 目录中，不再依赖旧的 `~/.vim` 配置。

### `lua/config/keymaps.lua`

管理全局快捷键。当前配置：

- 插入模式下输入 `jk`：返回普通模式

### `lua/config/commands.lua`

管理全局用户命令。当前配置：

- `:MakeTags`：在当前目录递归运行 `ctags -R .`

### `after/ftplugin/cpp.lua`

仅对 C++ 文件生效：

- 使用 2 个空格宽度，不自动展开 Tab
- `<F5>`：编译 `sol.cpp`
- `<F6>`：运行 `./sol`
- `:CpCompile`：执行 C++23 编译命令
- `:CpRun`：运行编译结果
- `:CP [name.cpp]`：创建 C++ 竞赛模板

### 其他 `after/ftplugin/*.lua`

- `markdown.lua`：4 空格缩进
- `python.lua`：4 空格缩进
- `vim.lua`：2 空格缩进

## 各运行时目录的用途

以下目录是 Neovim 支持的标准运行时目录。它们目前大多为空，但保留后可以直接按约定添加配置。

| 目录 | 用途 |
| --- | --- |
| `after/` | 覆盖默认运行时文件，通常用于最后加载的配置 |
| `autoload/` | Vimscript 按需加载的函数文件 |
| `compiler/` | 编译器配置，可通过 `:compiler` 选择 |
| `doc/` | 插件或配置的帮助文档，可通过 `:help` 查看 |
| `ftplugin/` | 按文件类型加载的插件配置 |
| `indent/` | 按文件类型提供缩进规则 |
| `keymap/` | 自定义键盘布局 |
| `menu/` | GUI 菜单定义 |
| `pack/` | Neovim 原生插件包目录 |
| `parser/` | Tree-sitter 解析器文件 |
| `plugin/` | 启动时自动执行的 Lua 或 Vimscript 插件文件 |
| `queries/` | Tree-sitter 高亮、注入和折叠查询 |
| `rplugin/` | Remote plugin 注册文件 |
| `spell/` | 拼写检查词典和规则 |
| `syntax/` | 语法高亮定义 |
| `tutor/` | Tutor 教程文件 |

## 添加新配置的建议

通用选项放入 `lua/config/options.lua`，全局快捷键放入 `lua/config/keymaps.lua`，全局命令放入 `lua/config/commands.lua`。

针对某种文件类型的设置放入 `after/ftplugin/<filetype>.lua`，例如：

```text
after/ftplugin/javascript.lua
```

需要启动时自动执行的独立 Lua 插件，可以放入 `plugin/`；需要手动按需加载的功能，则放入 `lua/` 并通过 `require()` 加载。
