local conform = require("conform")
conform.setup({
    formatters = {
        ["markdown-toc"] = {
            condition = function(_, ctx)
                for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
                    if line:find("<!%-%- toc %-%->") then
                        return true
                    end
                end
            end,
        },
        ["markdownlint-cli2"] = {
            condition = function(_, ctx)
                local diag = vim.tbl_filter(function(d)
                    return d.source == "markdownlint"
                end, vim.diagnostic.get(ctx.buf))
                return #diag > 0
            end,
        },
    },
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        rust = { "rustfmt", lsp_format = "fallback" },
        typescript = { "prettier" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier", "markdownlint-cli2" },
    },
    format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 700,
    },
})

vim.keymap.set({ "n", "v" }, "<leader>mp", function()
    conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 700,
    })
end)
