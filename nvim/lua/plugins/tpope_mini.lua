return {
  -- tpope's vim-commentary
  {
    "tpope/vim-commentary",
    event = "VeryLazy",
  },

  -- tpope's vim-surround
  {
    "tpope/vim-surround",
    event = "VeryLazy",
    config = function()
      -- Bind 'c' to JSX block comments {/* ... */}
      -- ASCII code for 'c' is 99
      vim.g["surround_99"] = "{/* \r */}"
    end,
  },
}
