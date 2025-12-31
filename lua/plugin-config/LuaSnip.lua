
local M = {
    "L3MON4D3/LuaSnip",
    tag = "v2.*",
    run = "make install_jsregexp"
}

function M.config() 
    require "luasnip.loaders.from_vscode".lazy_load {
    
    }
end


return M
