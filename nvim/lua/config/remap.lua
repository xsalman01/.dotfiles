vim.keymap.set("n", "Q", "<nop>")

-- Tabs
vim.keymap.set('n', '<Leader>1', '1gt', {desc = "go to first tab"})
vim.keymap.set('n', '<Leader>2', '2gt', {desc = "go to second tab"})
vim.keymap.set('n', '<Leader>3', '3gt', {desc = "go to third tab"})
vim.keymap.set('n', '<Leader>4', '4gt', {desc = "go to forth tab"})
vim.keymap.set('n', '<Leader>5', '5gt', {desc = "go to fifth tab"})

-- Quickfix navigation
local function toggle_quickfix()
    local qf_open = false
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win["quickfix"] == 1 then
            qf_open = true
            break
        end
    end

    if qf_open then
        vim.cmd("cclose")
    else
        vim.cmd("copen")
    end
end

vim.keymap.set("n", "<leader>q", toggle_quickfix, { silent = true, desc = "Toggle quickfixlist"})
vim.keymap.set("n", "]q", ":cnext<CR>", {desc = "go to next file in quickfix list"})
vim.keymap.set("n", "[q", ":cprev<CR>", {desc = "go to prev file in quickfix list"})
vim.keymap.set("n", "]Q", "<cmd>clast<CR>", {desc = "go to last file in quickfix list"})
vim.keymap.set("n", "[Q", "<cmd>cfirst<CR>", {desc = "go to first file in quickfix list"})

-- buffer
vim.keymap.set("n", "]b", ":bnext<CR>zz", {desc = "go to next buffer"})
vim.keymap.set("n", "[b", ":bprevious<CR>zz", {desc = "go to prev buffer"})
vim.keymap.set("n", "]B", ":blast<CR>zz", {desc = "go to last buffer"})
vim.keymap.set("n", "[B", ":bfirst<CR>zz", {desc = "go to first buffer"})

-- general
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, {desc = "open netrw"})

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "[[", "[[zz")
vim.keymap.set("n", "]]", "]]zz")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>", {desc = "restart lsp"})

-- greatest remap ever
vim.keymap.set("x", "<leader>p", '"_dP', {desc = "Paste without overwriting the yank register"})

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', {desc = "yank to clipboard"})
vim.keymap.set("n", "<leader>Y", '"+Y', {desc = "yank to both clipboard and register"})

vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", {desc = "delete without yanking"})

-- tmux sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", {desc = "open tmux sessionizer"})
-- for quick commands
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", {desc = "run first tmux sessionizer command"})
vim.keymap.set("n", "<M-t>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>", {desc = "run second tmux sessionizer command"})
-- vim.keymap.set("n", "<M-n>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>")
-- vim.keymap.set("n", "<M-s>", "<cmd>silent !tmux neww tmux-sessionizer -s 3<CR>")

vim.keymap.set("n", "<leader>l", vim.lsp.buf.format, {desc = "format buffer using lsp.buf.format"})

vim.keymap.set("n", "<leader>s", ':%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>', {desc = "select the word under cursor to substitute"})
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true }, {desc = "make current file executable"})

