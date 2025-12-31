local M = {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    tag = "v2.*",
    run = "make install_jsregexp"
}

function M.config() 
    local ls_vscode = require("luasnip.loaders.from_vscode")

    ls_vscode.lazy_load()

    for _, file in ipairs({
        "acm.code-snippets",
        "python.code-snippets",
    }) do
        ls_vscode.load_standalone({
            path = vim.fn.expand("~/.config/nvim/code-snippets/" .. file),
        })
    end
end


return M
