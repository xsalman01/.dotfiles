return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'BurntSushi/ripgrep',
        'nvim-tree/nvim-web-devicons',
    },
    cmd = { "Telescope", "TelescopeFindFiles", "TelescopeBuffers", "TelescopeLiveGrep" },
    config = function()
        local action_state = require("telescope.actions.state")

        local yank_display = function(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            local row = picker:get_selection_row()
            local entry = picker.manager:get_entry(picker:get_index(row))
            local display = entry.display
            if type(display) == 'function' then
                local _display_highlight
                display, _display_highlight = entry:display()
            end

            if type(display) == 'string' then
                vim.fn.setreg('+', display)
            else
                print("Could not extract display text.\n")
            end
        end

        require('telescope').setup({
            defaults = {
                mappings = {
                    i = {
                        ["<C-y>"] = yank_display,
                    },
                    n = {
                        ["<C-y>"] = yank_display,
                    },
                },
            },
        })

        local builtin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
    end
}
