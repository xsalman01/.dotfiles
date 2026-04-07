return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    branch = "main",

    config = function()
        require('nvim-treesitter').setup {}

        local ensureInstalled = { "javascript", "typescript",
            "html", "css", "lua", "vim", "vimdoc",
            "bash", "markdown", "markdown_inline"
        }
        local ts = require('nvim-treesitter')
        local parsersToInstall = vim.iter(ensureInstalled)
            :filter(function(p)
                return not vim.tbl_contains(ts.get_installed(), p)
            end)
            :totable()
        if #parsersToInstall > 0 then
            ts.install(parsersToInstall)
        end

        vim.api.nvim_create_autocmd('FileType', {
            callback = function()
                pcall(vim.treesitter.start)
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
