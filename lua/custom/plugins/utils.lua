local add_numbers = function()
  local lines = vim.api.nvim_buf_get_lines(0, vim.fn.getpos("'<")[2] - 1, vim.fn.getpos("'>")[2], false)
  local result = vim.iter(lines):fold(0, function(acc, line)
    local match = vim.re.match(line, "s <- {%d+'.'%d*} / {%d+} / . s")
    local num = tonumber(match or 0)
    return acc + num
  end)
  vim.print(result)
  vim.fn.setreg('+', result)
  -- a 12
  -- 	b 13.1
  -- 	c 10.9
  -- 	d
  -- 	e
end

return {
  add_numbers = add_numbers,
}
