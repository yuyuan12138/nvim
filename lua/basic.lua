-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true
-- 设置默认文件格式为 Unix (LF)
vim.opt.fileformat = "unix"

-- 文件格式检测优先级：Unix > DOS
vim.opt.fileformats = "unix,dos"
-- ================== 基本设置 ==================
vim.opt.compatible = false       -- 关闭兼容模式
vim.opt.syntax = 'on'            -- 开启语法高亮
vim.opt.number = true            -- 显示行号
vim.opt.relativenumber = true    -- 显示相对行号
vim.opt.tabstop = 4              -- Tab 宽度
vim.opt.shiftwidth = 4         -- 缩进宽度
vim.opt.expandtab = true         -- Tab 转空格
vim.opt.autoindent = true        -- 自动缩进
vim.opt.smartindent = true       -- 智能缩进
vim.opt.wrap = false             -- 不自动换行
vim.opt.backspace = 'indent,eol,start' -- 改进退格键
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.fileformats = 'unix,dos' -- 支持 Unix/Windows 换行符
vim.opt.colorcolumn = '120'

-- ================== 搜索 =================n
vim.opt.ignorecase = true        -- 忽略大小写
vim.opt.smartcase = true         -- 有大写时区分大小写
vim.opt.hlsearch = true          -- 高亮搜索
vim.opt.incsearch = true         -- 增量搜索

-- ================== LSP ==================

-- ================== 其他便捷设置 ==================
vim.opt.mouse = 'a'             -- 开启鼠标支持
vim.opt.showcmd = true           -- 显示命令
vim.opt.ruler = true             -- 显示光标位置
vim.opt.laststatus = 2           -- 总是显示状态栏


-- ========= buffer line
vim.opt.termguicolors = true

vim.g.mapleader = " "
