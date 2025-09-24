-- vim.api.nvim_create_autocmd("BufWritePre", {
--     pattern = "*.cs",
--     callback = function()
--         vim.fn.jobstart("csharpier --skip-restore" .. vim.fn.expand("%"), {
--             detach = true, --  Runs asynchronously, prevents blocking
--         })
--     end,
-- })

vim.g.dotnet_errors_only = true -- Show warnings?
vim.g.dotnet_show_project_file = false -- Get rid of the path to the file at the end of the quick fix display

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        local root = vim.fn.getcwd()
        local csproj_files = vim.fn.globpath(root, "*.csproj", false, true)
            or vim.fn.globpath(root, "*.sln", false, true)
        if #csproj_files > 0 then
            -- vim.opt_local.makeprg = "dotnet build"
            -- vim.opt_local.errorformat = "%f(%l,%c): %t%*[^:]: %m"
            vim.cmd("compiler dotnet")
        end
    end,
})

-- vim.api.nvim_create_autocmd("BufRead", {
--     pattern = "cs",
--     callback = function()
--         vim.cmd("echo test")
--         vim.fn.matchadd("csharpXmlTag", "<summary>")
--     end,
-- })
-- vim.api.nvim_set_hl(0, "csharpXmlTag", { fg = "#FFB86C", italic = true })
vim.api.nvim_create_autocmd("filetype", {
    pattern = "cs",
    callback = function()
        vim.fn.matchadd("csharpXmlTag", [[<\(/summary\|summary\)>]])
        vim.fn.matchadd("csharpXmlTag", [[<\(/remarks\|remarks\)>]])
        vim.fn.matchadd("csharpXmlTag", [[<\(/returns\|returns\)>]])
        vim.fn.matchadd("csharpXmlTag", "</exception>")
        vim.fn.matchadd("csharpXmlTag", [[<\(/code\|code\)>]])
        vim.fn.matchadd("csharpXmlTag", [[<param\s\+name="[^"]\+">]])
        vim.fn.matchadd("csharpXmlTag", [[<exception\s\+cref="[^"]\+">]])
    end,
})
vim.api.nvim_set_hl(0, "csharpXmlTag", { fg = "#41a7fc", italic = true })
vim.api.nvim_set_hl(0, "@comment", { fg = "#6c7d9c", italic = true })

local ls = require("luasnip")

-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local types = require("luasnip.util.types")

--[[ csharp snippets ]]

-- summay
ls.add_snippets("cs", {
    s(
        "/// summary",
        fmt(
            [[
///<summary>
/// {}
///</summary>
    ]],
            { i(1) }
        )
    ),
})
