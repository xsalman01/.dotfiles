return {
    "L3MON4D3/LuaSnip",
    version = "v2.*", -- latest v2 release
    build = "make install_jsregexp",
    dependencies = {
        "rafamadriz/friendly-snippets", -- adds snippets for many languages including astro, react
    },
    config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
    end,
}
