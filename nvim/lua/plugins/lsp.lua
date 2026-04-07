return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim"
    },

    config = function()
        vim.lsp.document_color.enable(true, nil, { style = 'virtual' })

        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities()
        )

        require("fidget").setup({})
        require("mason").setup()

        require("mason-tool-installer").setup({
            ensure_installed = {
                "css-lsp",
                "eslint_d",
                "json-lsp",
                "prettierd",
                "lua-language-server",
                "tailwindcss-language-server",
                "bash-language-server",
                "vim-language-server",
                "typescript-language-server"
            },
        })

        -- Global capabilities for all servers
        vim.lsp.config('*', { capabilities = capabilities })

        -- Per-server overrides
        vim.lsp.config("rust_analyzer", {
            settings = {
                ["rust-analyzer"] = {
                    checkOnSave = { command = "clippy" },
                },
            },
        })

        vim.lsp.config("qmlls", {
            cmd = { "qmlls", "-E" },
        })

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    workspace = {
                        checkThirdParty = false,
                        library = { vim.env.VIMRUNTIME .. "/lua" },
                    },
                    diagnostics = {
                        globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                    },
                },
            },
        })

        require("mason-lspconfig").setup({ automatic_enable = true })
    end
}
