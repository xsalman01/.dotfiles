return {
    "tpope/vim-fugitive",

    config = function()
        vim.keymap.set("n", "<leader>gs", function()
            vim.cmd("vertical Git")
        end, {desc = "Show git status"})

        vim.keymap.set("n", "<leader>gd", ":Gvdiff<CR>", {desc = "vertical git diff split current file"})

        -- merge conflicts
        vim.keymap.set("n", "<leader>ms", ":Gvdiffsplit!<CR>", {desc = "three way git split"})
        vim.keymap.set("n", "<leader>mg", ":diffget ", {desc = "get changes from selected git buffer"})
        vim.keymap.set("n", "<leader>mp", ":diffput ", {desc = "put changes to selected git buffer"})
    end
}
