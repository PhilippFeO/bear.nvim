local M = {}

--- Returns the text spanned by the last visual selection (the '< / '> marks).
--- Supports charwise, linewise and blockwise selections; multi-line selections
--- are joined with a single space so the result is usable as one expression.
---@return string selection The selected text, or "" if no selection is set.
function M.get_visual_selection()
  -- To use the `'<` and `'>` marks, we have to leave Visual mode.
  vim.cmd('normal! ' .. vim.api.nvim_replace_termcodes('<ESC>', true, false, true))
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  if #lines == 0 then
    return ""
  end

  -- Trim the first/last line to the selected columns; string.sub clamps
  -- out-of-range end columns (e.g. linewise selections use maxcol) safely.
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col, end_col)
  else
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  -- join with " " to have a one line python expression
  print(table.concat(lines, " "))
  return table.concat(lines, " ")
end

function M.clean_cache(opts)
  local answer = vim.fn.input("Clear cache? (y/n): ")
  if answer == "y" or answer == "Y" then
    vim.fn.system("rm -f " .. opts.cache_dir .. "/*")
    vim.notify("Cache cleared", vim.log.levels.INFO)
  end
end

return M
