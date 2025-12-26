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
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            {},
            cmp_lsp.default_capabilities()
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

        require("mason-lspconfig").setup({
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities,
                    }
                end,

                ["qmlls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.qmlls.setup {
                        capabilities = capabilities,
                        cmd = { "qmlls", "-E" },
                    }
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "LuaJIT" },
                                workspace = {
                                    checkThirdParty = false,
                                    library = {
                                        vim.env.VIMRUNTIME .. '/lua',
                                    },
                                },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
            }
        })
        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
