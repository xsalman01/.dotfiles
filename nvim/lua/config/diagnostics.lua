-- Telescope diagnostics keybindings with multiline wrapping
local ok, telescope_builtin = pcall(require, "telescope.builtin")
if ok then
    vim.keymap.set("n", "<leader>tc", function()
        telescope_builtin.diagnostics({
            bufnr = 0,           -- Current buffer only
            wrap_results = true, -- Allow multiline wrapping
        })
    end, { desc = "Telescope diagnostics (current buffer)" })

    vim.keymap.set("n", "<leader>tw", function()
        telescope_builtin.diagnostics({
            wrap_results = true, -- Entire workspace
        })
    end, { desc = "Telescope diagnostics (workspace)" })
else
    vim.notify("Telescope not found. Diagnostic keymaps not set.", vim.log.levels.WARN)
end

-- Auto-show diagnostic float when cursor is on a diagnostic

vim.diagnostic.config({
    virtual_text = true,      -- Show diagnostics as virtual text
    signs = true,             -- Show signs in the sign column
    underline = true,         -- Underline text with issues
    update_in_insert = false, -- Don't update diagnostics in insert mode
    severity_sort = true,     -- Sort diagnostics by severity
    float = {
        border = "rounded",   -- Nice rounded borders
        source = "always",    -- Always show source
        header = "",          -- No header
        prefix = "",          -- No prefix
        focusable = false,    -- Make the float non-focusable
        style = "minimal",    -- Minimal style for reduced background impact
    },
})

-- Set up float highlight group to use transparent background
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        -- Link the floating window highlight to NormalFloat
        vim.api.nvim_set_hl(0, "NormalFloat", {
            bg = "NONE",    -- Use NONE for transparent background
            link = "Normal" -- Inherit text color from Normal
        })

        -- Also ensure border is visible but subtle
        vim.api.nvim_set_hl(0, "FloatBorder", {
            fg = "gray",
            bg = "NONE"
        })
    end,
})

-- Execute once immediately to apply to current colorscheme
vim.cmd("doautocmd ColorScheme")

-- Create an autocommand group for the cursor hover diagnostic
local diagnostic_hover_augroup = vim.api.nvim_create_augroup("DiagnosticHover", { clear = true })

-- Flag to track if auto hover is enabled
local auto_hover_enabled = false

-- Function to create the auto hover functionality
local function setup_auto_hover()
    -- Clear any existing autocmds in the group
    vim.api.nvim_clear_autocmds({ group = diagnostic_hover_augroup })

    if auto_hover_enabled then
        -- Create an autocommand to show diagnostics when the cursor stops moving
        vim.api.nvim_create_autocmd("CursorHold", {
            group = diagnostic_hover_augroup,
            callback = function()
                vim.diagnostic.open_float({ focus = false, scope = "cursor" })
            end,
        })
    end
end

-- Function to toggle auto hover
local function toggle_auto_hover()
    auto_hover_enabled = not auto_hover_enabled
    setup_auto_hover()
end

-- Set up the initial auto hover state
setup_auto_hover()

-- Keybinding to toggle the auto hover functionality
vim.keymap.set('n', '<leader>ad', toggle_auto_hover, { desc = 'Toggle auto diagnostic hover' })
vim.opt.updatetime = 150 -- Default is 4000ms which is quite slow
