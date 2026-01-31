-- Remove spaces at the end of a line
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        pcall(function()
            vim.cmd([[%s/\s\+$//e]])
        end)
        vim.fn.setpos(".", save_cursor)
    end,
})

-- Highlight when yanking (copying) text
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Folds ------------------------------------------------------------------------------------------
--
-- Enable folds if there is a treesitter for this filetype
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        local ok = pcall(vim.treesitter.get_parser, 0)

        if ok then
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        else
            vim.opt_local.foldmethod = "syntax"
        end
    end,
})

-- Powershell -------------------------------------------------------------------------------------
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = "ps1",
--     callback = function()
--         vim.keymap.set("n", "<leader>r", function()
--             local word = vim.fn.expand("<cword>")
--             local replacement = vim.fn.input("Replace " .. word .. " with: ")
--             if replacement ~= "" then
--                 vim.cmd(":%s/" .. word .. "/" .. replacement .. "/gc")
--             end
--         end, { buffer = true }) -- `buffer = true` ensures it applies only to the current file
--     end,
-- })

-- Search Colors ----------------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
    callback = function()
        vim.api.nvim_set_hl(0, "Search", {
            bg = "#56b6c2",
            fg = "#282c34",
        })
    end,
})

-- XML --------------------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
    pattern = "xml",
    callback = function()
        vim.opt_local.expandtab = true -- use spaces instead of table
        vim.opt_local.tabstop = 2 -- number of spaces per tab
        vim.opt_local.shiftwidth = 2 -- indentation width
        vim.opt_local.softtabstop = 2 -- editing width for tabs
    end,
})
