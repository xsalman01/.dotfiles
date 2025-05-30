return {
    "ahmedkhalf/project.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        detection_methods = { "pattern" },
        patterns = { ".git", "Makefile", "package.json" },
    },
    config = function(_, opts)
        require("project_nvim").setup(opts)
    end
}
