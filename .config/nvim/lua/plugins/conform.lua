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
        csharpier = {
            command = "csharpier",
            args = { "format", "$FILENAME", "--write-stdout" },
            stdin = true,
        },
    },
    formatters_by_ft = {
        cs = { "csharpier" },
        lua = { "stylua" },
        python = { "isort", "black" },
        rust = { "rustfmt", lsp_format = "fallback" },
        typescript = { "prettier" },
        javascript = { "prettier", stop_after_first = true },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettierd", timeout_ms = 2000 },
    },
    format_on_save = false,
    format_after_save = {
        lsp_fallback = true,
        timeout_ms = 700,
    },
})
