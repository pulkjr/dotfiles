require("treesitter-modules").setup({

    ensure_installed = {
        "bash",
        "diff",
        "dockerfile",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "mermaid",
        "toml",
        "vim",
        "vimdoc",
    },
    sync_install = false,

    auto_install = true,

    indent = {
        enable = true,
    },

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<leader>vv",
            node_incremental = "<leader>vi",
            scope_incremental = "<leader>vc",
            node_decremental = "<leader>vd",
        },
    },
})
require("nvim-treesitter-textobjects").setup({
    select = {
        -- automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        -- you can choose the select mode (default is charwise 'v')
        --
        -- can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'v', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "v", -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
        },
        -- if you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        --
        -- can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * selection_mode: eg 'v'
        -- and should return true or false
        include_surrounding_whitespace = true,
        -- Textobject creates jums for the parts of a function or class
        move = {
            set_jumps = true,
        },
    },
})
-- keymaps
-- Visual Select parts of the code
vim.keymap.set({ "x", "o" }, "af", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end, { desc = "Select [A]round [F]unction" })
vim.keymap.set({ "x", "o" }, "if", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end, { desc = "Select [I]nside [F]unction" })
vim.keymap.set({ "x", "o" }, "ac", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end, { desc = "Select [A]round [C]lass" })
vim.keymap.set({ "x", "o" }, "ic", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end, { desc = "Select [I]nside [C]lass" })
-- You can also use captures from other query groups like `locals.scm`
vim.keymap.set({ "x", "o" }, "as", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
end, { desc = "Select [A]round local [S]cope" })

--Move the cursor to next/previous function or class

vim.keymap.set({ "n", "x", "o" }, "]m", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
end, { desc = "Go to [N]ext function [S]tart" })

-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
vim.keymap.set({ "n", "x", "o" }, "]z", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
end, { desc = "Go to [N]ext [F]old start" })

vim.keymap.set({ "n", "x", "o" }, "]M", function()
    require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
end, { desc = "Go to [N]ext function [E]nd" })

vim.keymap.set({ "n", "x", "o" }, "[m", function()
    require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
end, { desc = "Go to [P]revious function [S]tart" })

vim.keymap.set({ "n", "x", "o" }, "[M", function()
    require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
end, { desc = "Go to [P]revious function [E]nd" })

-- refactor = {
--     highlight_definitions = {
--         enable = true,
--         -- Set to false if you have an `updatetime` of ~100.
--         clear_on_cursor_move = true,
--     },
--     smart_rename = {
--         enable = true,
--         -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
--         keymaps = {
--             smart_rename = "grr",
--         },
--     },
-- },
-- })
