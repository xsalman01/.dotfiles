local function find_project_root(filepath)
  local uv = vim.loop

  local function is_git_dir(path)
    return uv.fs_stat(path .. "/.git") ~= nil
  end

  local dir = vim.fn.fnamemodify(filepath, ":p:h")
  while dir ~= "/" and not is_git_dir(dir) do
    dir = vim.fn.fnamemodify(dir, ":h")
  end

  if is_git_dir(dir) then
    return dir
  else
    return vim.env.HOME
  end
end

function Get_path()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then return "" end

  local root = find_project_root(filepath)
  local relpath = vim.fn.fnamemodify(filepath, ":p"):gsub("^" .. root .. "/", "")
  return "%#Directory#%* " .. relpath
end

return {
    'maxmx03/roseline',
    opts = {
        layout = {
            a = section_a,
            b = section_b,
            c = function() return GetFilePath() end,
            d = section_d,
            e = section_e,
        }
    },
    dependencies = {
      'rose-pine/neovim',
    }
}
