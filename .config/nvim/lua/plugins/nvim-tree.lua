-- lua/plugins/nvim-tree.lua
return {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons', -- Optional, for file icons
  },
  config = function()
    require('config.nvim-tree') -- Load your nvim-tree configuration
  end,
}
