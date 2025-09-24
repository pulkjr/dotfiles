require("nvim-treesitter.configs").setup({

    ensure_installed = {
        "bash",
        "c_sharp",
        "css",
        "diff",
        "dockerfile",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "mermaid",
        "python",
        "rust",
        "sql",
        "toml",
        "typescript",
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
        disable = { "comment" },
    },
    textobjects = {
        select = {
            enable = true,

            -- automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
                ["af"] = { query = "@function.outer", desc = "select outer part of a function region" },
                ["if"] = { query = "@function.inner", desc = "select inner part of a function region" },
                ["ac"] = { query = "@class.outer", desc = "select outer part of a class region" },
                ["ic"] = { query = "@class.inner", desc = "select inner part of a class region" },
                ["as"] = { query = "@local.scope", query_group = "locals", desc = "select language scope" },
            },
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
        },
    },
    refactor = {
        highlight_definitions = {
            enable = true,
            -- Set to false if you have an `updatetime` of ~100.
            clear_on_cursor_move = true,
        },
        smart_rename = {
            enable = true,
            -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
            keymaps = {
                smart_rename = "grr",
            },
        },
    },
})

local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
treesitter_parser_config.powershell = {
    install_info = {
        url = "~/.config/nvim/tree-sitter-parsers/tree-sitter-powershell",
        files = { "src/parser.c", "src/scanner.c" },
        branch = "main",
        generate_requires_npm = false,
        requires_generate_from_grammar = false,
    },
    filetype = "ps1",
}
