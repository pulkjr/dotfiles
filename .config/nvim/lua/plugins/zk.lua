require("zk").setup({
    picker = "telescope",
    lsp = {
        completion = {
            matchStrategy = "strict",
        },
        config = {
            cmd = { "zk", "lsp" },
            name = "zk",
        },
        auto_attach = {
            enabled = true,
            filetypes = { "markdown" },
        },
    },
})
