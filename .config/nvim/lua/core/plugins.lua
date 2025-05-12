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

        -- LSP PLUGINS ----------------------------------------------------------------------------
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",

        -- SNIPPETS -------------------------------------------------------------------------------
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",

        -- DEBUGGER -------------------------------------------------------------------------------
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

        -- LINTING --------------------------------------------------------------------------------
        {
            "stevearc/conform.nvim",
            event = { "BufReadPre", "BufNewFile" },
        },

        --telescope Fuzzy Finder
        {
            "nvim-telescope/telescope.nvim",
            event = "VimEnter",
            branch = "0.1.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                {
                    -- If encountering errors, see telescope-fzf-native README for installation instructions
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

        -- NAVIGATION -----------------------------------------------------------------------------
        -- Working with multiple cursors
        "mg979/vim-visual-multi",

        -- Navigating to different files within a project
        {
            "theprimeagen/harpoon",
            branch = "harpoon2",
            dependencies = { "nvim-lua/plenary.nvim" },
        },

        -- GIT ------------------------------------------------------------------------------------
        "tpope/vim-fugitive",
        "lewis6991/gitsigns.nvim",

        -- NOTE -----------------------------------------------------------------------------------
        "zk-org/zk-nvim",

        -- lOOK AND FEEL --------------------------------------------------------------------------
        {
            "windwp/nvim-autopairs",
            event = "InsertEnter",
            config = true,
        },
        -- Highlight the words under cursor
        { "echasnovski/mini.cursorword", version = "*" },

        -- Progress UI in the bottom right
        "j-hui/fidget.nvim",

        -- Breadcruoms from the LSP
        "nvimdev/lspsaga.nvim",

        -- MARKDOWN -------------------------------------------------------------------------------
        "jghauser/follow-md-links.nvim",
        -- Makes working with Markdown Tables better
        "Kicamon/markdown-table-mode.nvim",
        -- Renders markdown nicely
        {
            "MeanderingProgrammer/render-markdown.nvim",
            enabled = true,
            dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        },
    },
    -- LAZY CONFIGURATION -------------------------------------------------------------------------
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
