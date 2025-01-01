return {
	'nvim-telescope/telescope.nvim', 
	tag = '0.1.8',
	dependencies = { 
        'nvim-lua/plenary.nvim',
        'BurntSushi/ripgrep',
        'nvim-tree/nvim-web-devicons',
    },

	config = function()
		require('telescope').setup({})
	
		local builtin = require('telescope.builtin')

		vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
		vim.keymap.set('n', '<C-p>', builtin.git_files, {})
		vim.keymap.set('n', '<leader>ps', function()
			builtin.grep_string( { search = vim.fn.input("Grep > ") });
		end)
	end
}
