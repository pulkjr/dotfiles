local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

return {
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            hover = {
                memoryLayout = {
                    alignment = "hexadecimal", -- or "decimal"
                    size = "both", -- shows both decimal and hexadecimal
                },
            },
            check = {
                command = "clippy",
            },
            cargo = {
                features = "all",
            },
            rustfmt = {
                overrideCommand = { "leptosfmt", "--stdin", "--rustfmt" },
            },
            procMacro = {
                ignored = {
                    leptos_macro = { -- ignore leptos macros
                        "server",
                    },
                },
            },
        },
    },
}
