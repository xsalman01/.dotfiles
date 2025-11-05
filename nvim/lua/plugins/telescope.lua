return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'BurntSushi/ripgrep',
        'nvim-tree/nvim-web-devicons',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
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
            extensions = {
                fzf = {}
            }
        })

        require('telescope').load_extension('fzf')
        local builtin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Find files' })
        vim.keymap.set('n', '<leader>pF', builtin.current_buffer_fuzzy_find, { desc = 'Current buffer fzf' })
        vim.keymap.set('n', '<leader>ph', builtin.help_tags, { desc = 'Help Tags' })
        vim.keymap.set('n', '<leader>pg', builtin.git_status, { desc = 'Git status in telescope' })
        vim.keymap.set('n', '<leader>pb', builtin.buffers, { desc = 'Current buffers in telescope' })
        vim.keymap.set('n', '<leader>pS', builtin.git_stash, { desc = 'Stashed files in telescope' })
        vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "Git files in telescope"})
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end, {desc = "Fuzzy find word"})
    end
}
