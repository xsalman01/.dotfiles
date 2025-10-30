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
                "tsgo"
            },
        })

        require("mason-lspconfig").setup({
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities,
                    }
                end,

                ["tsgo"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.tsgo.setup({
                        capabilities = capabilities,

                        cmd = { "tsgo", "--lsp", "--stdio" },
                        filetypes = {
                            "javascript",
                            "javascriptreact",
                            "javascript.jsx",
                            "typescript",
                            "typescriptreact",
                            "typescript.tsx",
                        },
                        root_dir = function(bufnr)
                            local root_markers = {
                                "package-lock.json",
                                "yarn.lock",
                                "pnpm-lock.yaml",
                                "bun.lockb",
                                "bun.lock",
                                ".git",
                            }
                            return vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
                        end,
                    })
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
