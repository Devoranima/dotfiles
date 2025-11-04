local autocmd_group = vim.api.nvim_create_augroup("Custom auto-cmds", {
  clear = true,
})

vim.api.nvim_create_autocmd({"BufWritePost"}, {
  pattern = {"*.py"},
  desc = "Auto-format Python files after saving",
  callback = function ()
    local fileName = vim.api.nvim_buf_get_name(0)
    -- vim.cmd(":silent !autopep8 --in-place -aa " .. fileName)
    vim.cmd(":silent !isort --profile google --float-to-top -q " .. fileName)
    vim.cmd(":silent !docformatter --in-place " .. fileName)
  end,
  group = autocmd_group
})

local FormatCallback = function ()
    local fileName = vim.api.nvim_buf_get_name(0)
    local fileExtension = fileName:match("^.+(%..+)$")
    if fileExtension == ".py" then
        vim.cmd(":silent !autopep8 --in-place -aa --experimental " .. fileName)
    end
end

vim.api.nvim_create_user_command("Format", FormatCallback, {})
