return {
      'sainnhe/gruvbox-material',
      lazy = false,
      priority = 1000,
      config = function()
        -- Optionally configure and load the colorscheme
        -- directly inside the plugin declaration.
        vim.g.gruvbox_material_transparent_background = 2
        vim.g.gruvbox_material_foreground = "original"
      end
}
