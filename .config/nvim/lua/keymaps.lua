-- Common rules
local opts = {
  noremap = true,
  silent = true,
}

-----------------
-- Normal mode --
-----------------

-- Window navigation
vim.keymap.set('n', '<C-Right>', '<C-w>Right', opts)
vim.keymap.set('n', '<C-Down>', '<C-w>Down', opts)
vim.keymap.set('n', '<C-Left>', '<C-w>Left', opts)
vim.keymap.set('n', '<C-Up>', '<C-w>Top', opts)

-- Resize 
vim.keymap.set('n', '<sc-Right>', ':vertical resize +2<CR>', opts)
vim.keymap.set('n', '<sc-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<sc-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<sc-Up>', ':resize -2<CR>', opts)

-- Splits Managment
vim.keymap.set('n', '<leader><leader>h', ':split', opts)
vim.keymap.set('n', '<leader><leader>v', ':vertical split', opts)

-----------------
-- Visual mode --
-----------------

vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)


