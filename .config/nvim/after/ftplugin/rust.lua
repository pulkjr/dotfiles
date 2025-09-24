-- Treesitter folding
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

vim.api.nvim_set_hl(0, "xmlTag", { fg = "yellow", undercurl = true, force = true })
