return   {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")

    lspconfig.pylsp.setup({
      settings = {
        pylsp = {
          plugins = {
            pyflakes = {enabled = true},
            pylint = {enabled = false},
            pycodestyle = {
                enabled = true,
                ignore = {'E501'},
            },
          },
        },
      },
    })
    lspconfig.bashls.setup({})
    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
          },
          diagnostics = {
            globals = {"vim"},
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = {
            enable = false,
          },
        },
      },
    })
  end,
}

