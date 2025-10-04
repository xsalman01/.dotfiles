return {
    "tpope/vim-fugitive",

    config = function()
        vim.keymap.set("n", "<leader>gs", function()
            vim.cmd("vertical Git")
        end)

        vim.keymap.set("n", "<leader>gd", ":Gvdiff<CR>")
        vim.keymap.set("n", "<leader>gD", ":Gvdiff")
        vim.keymap.set("n", "<leader>ga", ":Gwrite")
        vim.keymap.set("n", "<leader>gr", ":Gread")

        -- merge conflicts
        vim.keymap.set("n", "<leader>ms", ":Gvdiffsplit!")
        vim.keymap.set("n", "<leader>mg", ":diffget")
        vim.keymap.set("n", "<leader>mp", ":diffput")
    end
}
