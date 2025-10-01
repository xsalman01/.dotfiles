return {
    "nvim-lualine/lualine.nvim",
    event = "ColorScheme",
    config = function()
        require("lualine").setup({
            options = {
                component_separators = { left = "⎜", right = "⎜" },

                --- @usage 'rose-pine' | 'rose-pine-alt'
                theme = "rose-pine"
            },
            extensions = {'quickfix', 'fugitive', 'man'},

            sections = {
                lualine_c = {{
                        'filename',
                        path = 1,
                }},
                lualine_x = { 'fileformat', {
                    'lsp_status',
                    icon = "",
                    symbols = {
                        spinner = {},
                    },
                },'filetype' },
            },
        })
    end
}
