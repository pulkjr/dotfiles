vim.api.nvim_create_user_command("W", function()
    vim.cmd("w")
end, { desc = "Save this file" })

vim.api.nvim_create_user_command("Q", function()
    vim.cmd("q")
end, { desc = "Quit" })
