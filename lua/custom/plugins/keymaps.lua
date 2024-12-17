local setup = function()
  vim.keymap.set(
    'v',
    '<A-c>s',
    ':<C-u>lua require("custom.plugins.utils").add_numbers()<CR>',
    { silent = true, noremap = true, desc = 'Sum first number of selected lines.' }
  )
end

return {
  setup = setup,
}
