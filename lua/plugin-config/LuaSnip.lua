local M = {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    tag = "v2.*",
    run = "make install_jsregexp"
}

function M.config() 
    require("luasnip.loaders.from_vscode").lazy_load ({

    })
    require("luasnip.loaders.from_vscode").load_standalone({
        path="~/.config/nvim/code-snippets/acm.code-snippets"
    })
end


return M
