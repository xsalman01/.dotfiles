local Path = require("plenary.path")
local project = require("project_nvim.project")

function GetFilePath()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then return "" end

  local project_root = project.get_project_root()
  if not project_root or project_root == "" then
    project_root = vim.loop.os_homedir()
  end

  local path = Path:new(filepath)
  local relpath = path:make_relative(project_root)

  return "%#Directory#%* " .. relpath
end

