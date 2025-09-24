require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
    },
})

require("mason-lspconfig").setup({
    ensure_installed = {
        "lemminx",
        -- "ansible-lint",
        -- "black", -- python formatter
        -- "codelldp",
        -- "csharpier",
        -- "eslint_d", -- js linter
        -- "groovyls", -- This is not installing...
        -- "isort", -- python formatter
        -- "jsonlint",
        "lua_ls",
        -- "markdown-toc",
        -- "markdownlint",
        "marksman",
        -- "prettier", -- prettier formatter
        -- "pylint", -- python linter
        "rust_analyzer",
        -- "stylua", -- lua formatter
        -- "tsserver",
        -- "roslyn",
        "html",
        "cssls",
    },
})
