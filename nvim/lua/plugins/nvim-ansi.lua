return {
  "powerman/vim-plugin-AnsiEsc",
  config = function()
    vim.cmd("AnsiEsc")
    -- cecutil.vim registers <Leader>swp/<Leader>rwp for internal use;
    -- remove them to avoid timeoutlen delay on <Leader>s
    pcall(vim.cmd, "unmap <Leader>swp")
    pcall(vim.cmd, "unmap <Leader>rwp")
  end,
}
