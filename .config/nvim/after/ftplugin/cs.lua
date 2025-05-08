vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.cs",
    callback = function()
        vim.fn.jobstart("csharpier --skip-restore" .. vim.fn.expand("%"), {
            detach = true, --  Runs asynchronously, prevents blocking
        })
    end,
})
