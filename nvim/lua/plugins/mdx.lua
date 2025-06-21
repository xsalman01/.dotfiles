vim.filetype.add({
    extension = {
        mdx = "mdx",
    },
})

return {
  "davidmh/mdx.nvim",
  ft = "mdx",
  config = true,
  dependencies = {"nvim-treesitter/nvim-treesitter"}
}
