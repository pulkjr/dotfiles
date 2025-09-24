require("lazy").setup(
    {
        "navarasu/onedark.nvim",
        "nvim-treesitter/nvim-treesitter",
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            dependencies = {
                "nvim-treesitter/nvim-treesitter",
            },
        },
        {
            "nvim-treesitter/nvim-treesitter-refactor",
            dependencies = {
                "nvim-treesitter/nvim-treesitter",
            },
        },
        "nvim-lua/plenary.nvim",
        {
            "folke/todo-comments.nvim",
            event = "VimEnter",
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
            opts = { signs = false },
        },
        {
            "folke/lazydev.nvim", -- Helps with Neovim condiguration
            ft = "lua", -- only load on lua files
            opts = {
                library = {
                    -- See the configuration section for more details
                    -- Load luvit types when the `vim.uv` word is found
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },

        -- LSP PLUGINS ----------------------------------------------------------------------------
        "neovim/nvim-lspconfig",
        {
            "williamboman/mason.nvim",
            opts = {
                registries = {
                    "github:mason-org/mason-registry",
                    "github:Crashdummyy/mason-registry",
                },
            },
        },

        "williamboman/mason-lspconfig.nvim",
        -- "ray-x/lsp_signature.nvim", -- Look and feel of signature's
        {
            "seblyng/roslyn.nvim",
            ---@module 'roslyn.config'
            ---@type RoslynNvimConfig
            ft = { "cs", "razor" },
            opts = {
                -- your configuration comes here; leave empty for default settings
            },
        },

        -- SNIPPETS -------------------------------------------------------------------------------
        -- "hrsh7th/cmp-nvim-lsp",
        -- "hrsh7th/cmp-buffer",
        -- "hrsh7th/cmp-path",
        -- "hrsh7th/cmp-cmdline",
        -- "hrsh7th/nvim-cmp",
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            build = "make install_jsregexp",
        },
        -- "saadparwaiz1/cmp_luasnip",
        --
        "rafamadriz/friendly-snippets",
        {
            "saghen/blink.cmp",
            dependencies = {
                "rafamadriz/friendly-snippets",
                "L3MON4D3/LuaSnip",
            },

            -- use a release tag to download pre-built binaries
            version = "1.*",

            ---@module 'blink.cmp'
            ---@type blink.cmp.Config
            opts = {
                -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
                -- 'super-tab' for mappings similar to vscode (tab to accept)
                -- 'enter' for enter to accept
                -- 'none' for no mappings
                --
                -- All presets have the following mappings:
                -- C-space: Open menu or open docs if already open
                -- C-n/C-p or Up/Down: Select next/previous item
                -- C-e: Hide menu
                -- C-k: Toggle signature help (if signature.enabled = true)
                --
                -- See :h blink-cmp-config-keymap for defining your own keymap
                keymap = { preset = "default" },

                appearance = {
                    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                    -- Adjusts spacing to ensure icons are aligned
                    nerd_font_variant = "mono",
                },

                -- (Default) Only show the documentation popup when manually triggered
                completion = { documentation = { auto_show = true } },

                snippets = { preset = "luasnip" },

                -- Default list of enabled providers defined so that you can extend it
                -- elsewhere in your config, without redefining it, due to `opts_extend`
                sources = {
                    default = {
                        "lazydev",
                        "lsp",
                        "path",
                        "snippets",
                        "buffer",
                    },
                    providers = {
                        lazydev = {
                            name = "LazyDev",
                            module = "lazydev.integrations.blink",
                            -- make lazydev completions top priority (see `:h blink.cmp`)
                            score_offset = 100,
                        },
                    },
                },

                -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
                -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
                -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
                --
                -- See the fuzzy documentation for more information
                fuzzy = { implementation = "prefer_rust_with_warning" },
            },
            opts_extend = { "sources.default" },
        },

        -- DEBUGGER -------------------------------------------------------------------------------
        {
            "ramboe/ramboe-dotnet-utils",
            dependencies = { "mfussenegger/nvim-dap" },
        },
        {
            -- Debug Framework
            "mfussenegger/nvim-dap",
            dependencies = {
                "rcarriga/nvim-dap-ui",
            },
            config = function()
                require("core.plugin_configs.nvim-dap")
            end,
            event = "VeryLazy",
        },
        { "nvim-neotest/nvim-nio" },
        {
            -- UI for debugging
            "rcarriga/nvim-dap-ui",
            dependencies = {
                "mfussenegger/nvim-dap",
            },
            config = function()
                require("core.plugin_configs.nvim-dap-ui")
            end,
        },
        {
            "nvim-neotest/neotest",
            commit = "52fca6717ef972113ddd6ca223e30ad0abb2800c",
            requires = {
                {
                    "Issafalcon/neotest-dotnet",
                },
            },
            dependencies = {
                "nvim-neotest/nvim-nio",
                "nvim-lua/plenary.nvim",
                "antoinemadec/FixCursorHold.nvim",
                "nvim-treesitter/nvim-treesitter",
            },
        },
        {
            "Issafalcon/neotest-dotnet",
            lazy = false,
            dependencies = {
                "nvim-neotest/neotest",
            },
        },

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

        -- FUZZY FIND -----------------------------------------------------------------------------
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
        {
            "jfryy/keytrail.nvim",
            dependencies = {
                "nvim-treesitter/nvim-treesitter",
                "nvim-telescope/telescope.nvim",
            },
            config = function()
                require("keytrail").setup()
            end,
        },
        {
            "kylechui/nvim-surround",
            version = "^3.0.0",
            event = "VeryLazy",
            config = function()
                require("nvim-surround").setup({})
            end,
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
        -- "nvimdev/lspsaga.nvim", -- Don't see the value as I am ususally looking for the file I'm in

        -- MARKDOWN -------------------------------------------------------------------------------
        "jghauser/follow-md-links.nvim",
        -- Makes working with Markdown Tables better
        "Kicamon/markdown-table-mode.nvim",
        -- Renders markdown nicely
        -- Disabled as it is annoying in day to day use
        -- {
        --     "MeanderingProgrammer/render-markdown.nvim",
        --     enabled = true,
        --     dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        -- },
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
