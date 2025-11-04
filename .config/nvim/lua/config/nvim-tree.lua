-- lua/config/nvim-tree.lua

-- Disable netrw (recommended by nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Setup nvim-tree
require('nvim-tree').setup {
  sort = {
    sorter = 'case_sensitive',
  },
  view = {
    width = 30,
    side = 'left',
  },
  renderer = {
    group_empty = true,
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
  filters = {
    dotfiles = false, -- Show dotfiles by default
  },
}

-- Keymappings for nvim-tree
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Toggle nvim-tree
map('n', '<leader>e', '<Cmd>NvimTreeToggle<CR>', opts)
-- Focus nvim-tree
map('n', '<leader>fe', '<Cmd>NvimTreeFocus<CR>', opts)
--for Find current file in nvim-tree
map('n', '<leader>nf', '<Cmd>NvimTreeFindFile<CR>', opts)
