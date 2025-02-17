local mason = require("mason")

local mason_tool_installer = require("mason-tool-installer")

mason.setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
    },
})

mason_tool_installer.setup({
    ensure_installed = {
        "ansible-lint",
        "black", -- python formatter
        "codelldp",
        "eslint_d", -- js linter
        "groovyls",
        "isort", -- python formatter
        "jsonlint",
        "lua-language-server",
        "markdownlint",
        "markdownlint-cli2",
        "markdown-toc",
        "prettier", -- prettier formatter
        "pylint", -- python linter
        "rust-analyzer",
        "stylua", -- lua formatter
        "typescript-language-server",
    },
})
