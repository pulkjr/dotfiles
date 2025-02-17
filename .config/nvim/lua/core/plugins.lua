require("lazy").setup(
    {
        "navarasu/onedark.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-lua/plenary.nvim",
        {
            "folke/todo-comments.nvim",
            event = "VimEnter",
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
            opts = { signs = false },
        },
        { "echasnovski/mini.nvim", version = "*" },

        -- LSP Plugins -------------------------------------------
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
        {
            "theprimeagen/harpoon",
            branch = "harpoon2",
            dependencies = { "nvim-lua/plenary.nvim" },
        },

        -- Debugger
        "mfussenegger/nvim-dap",
        -- Need to troubleshoot this. It isn't working right now.
        -- {
        --     "mrcjkb/rustaceanvim",
        --     version = "^5", -- Recommended
        --     lazy = false, -- This plugin is already lazy
        -- },
        -- Lint
        -- {
        --     "mfussenegger/nvim-lint",
        --     event = { "BufReadPre", "BufNewFile" },
        -- },

        --Formatters
        {
            "stevearc/conform.nvim",
            event = { "BufReadPre", "BufNewFile" },
        },
        "norcalli/nvim-colorizer.lua", -- Show the color of a hex value in CSS and HTML
        -- Makes working with Markdown Tables better
        "Kicamon/markdown-table-mode.nvim",
        -- Renders markdown nicely
        {
            "MeanderingProgrammer/render-markdown.nvim",
            enabled = true,
            dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
            -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
            -- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
        },
        --learning vim
        "theprimeagen/vim-be-good",

        --telescope Fuzzy Finder
        {
            "nvim-telescope/telescope.nvim",
            event = "VimEnter",
            branch = "0.1.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                { -- If encountering errors, see telescope-fzf-native README for installation instructions
                    "nvim-telescope/telescope-fzf-native.nvim",

                    -- `build` is used to run some command when the plugin is installed/updated.
                    -- This is only run then, not every time Neovim starts up.
                    build = "make",

                    -- `cond` is a condition used to determine whether this plugin should be
                    -- installed and loaded.
                    cond = function()
                        return vim.fn.executable("make") == 1
                    end,
                },
                { "nvim-telescope/telescope-ui-select.nvim" },

                -- Useful for getting pretty icons, but requires a Nerd Font.
                { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
            },
        },

        --git
        "tpope/vim-fugitive",
        "lewis6991/gitsigns.nvim",

        --note
        "zk-org/zk-nvim",

        -- Look and feel
        {
            "windwp/nvim-autopairs",
            event = "InsertEnter",
            config = true,
        },
        "mg979/vim-visual-multi",
        "nvimdev/lspsaga.nvim",

        -- Markdown ---------------------------------------------
        "jghauser/follow-md-links.nvim",
    },
    -- Lazy Configuration -----------------------------------
    {
        ui = { border = "rounded" },
        install = {
            -- Automatically install on startup?
            missing = false,
        },
        -- Notify when a change to plugins is detected?
        change_detection = { notify = false },
        -- Disable luarocks
        rocks = {
            enabled = false,
        },
        performance = {
            rtp = {
                disabled_plugins = {
                    "gzip",
                    -- "netrwPlugin",
                    "rplugin",
                    "tarPlugin",
                    "tohtml",
                    "tutor",
                    "zipPlugin",
                },
            },
        },
    }
)
