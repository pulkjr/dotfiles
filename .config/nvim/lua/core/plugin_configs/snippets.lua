-- require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./.vscode" } })
require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/lua/snippets/" })
require("luasnip.loaders.from_vscode").load()
