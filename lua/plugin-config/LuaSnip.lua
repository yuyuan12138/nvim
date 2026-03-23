local M = {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    tag = "v2.*",
    run = "make install_jsregexp"
}

function M.config() 
    local ls_vscode = require("luasnip.loaders.from_vscode")

    ls_vscode.lazy_load()
    ls_vscode.load_standalone({ path = "/Users/yuyuan/cp/Wlib/cpp.code-snippets"})

end


return M
