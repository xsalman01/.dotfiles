local function get_file_path()
  local current_file = vim.fn.expand('%:p')
  
  if current_file == "" then
    return ""
  end
  
  local git_dir = vim.fn.finddir('.git', vim.fn.expand('%:p:h') .. ';')
  
  local relative_path = ""
  
  if git_dir ~= "" then
    local project_root = vim.fn.fnamemodify(git_dir, ':h')
    relative_path = vim.fn.fnamemodify(current_file, ':s?' .. project_root .. '/??')
  else
    local home_dir = vim.fn.expand('~')
    if vim.fn.stridx(current_file, home_dir) == 0 then
      relative_path = '~' .. current_file:sub(#home_dir + 1)
    else
      relative_path = current_file
    end
  end
  
  return "%#Directory#%* " .. relative_path
end

return {
    'maxmx03/roseline',
    opts = {
        layout = {
            a = section_a,
            b = section_b,
            c = get_file_path,
            d = section_d,
            e = section_e,
        }
    },
    dependencies = {
      'rose-pine/neovim',
    }
}
