local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")
local capabilities =
    vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), cmp_lsp.default_capabilities())

local lspconfig = require("lspconfig")

local on_attach = function(client, bufnr)
    -- Key mappings
    local k = vim.keymap

    -- Disable LSP Token highlight. Need to figure out how to only do this for PowerShell
    client.server_capabilities.semanticTokensProvider = nil

    local opts = { noremap = true, silent = true }
    k.set("n", "gD", "<cmd>Telescope lsp_type_definitions<CR>", opts)
    k.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
    k.set("n", "gn", vim.lsp.buf.rename, opts)
    k.set("n", "K", vim.lsp.buf.hover, opts)
    k.set("n", "gh", vim.lsp.buf.signature_help, opts)
    k.set("n", "gi", "<cmd>Telescope lsp_implementations>", opts)
    k.set("n", "gr", vim.lsp.buf.references, opts)
    k.set("n", "[d", vim.diagnostic.goto_prev, opts)
    k.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    k.set("n", "<leader>r", vim.lsp.buf.rename, opts)
end

require("fidget").setup({})
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "marksman",
    },
    handlers = {
        function(server_name)
            require("lspconfig")[server_name].setup({
                capabilities = capabilities,
            })
        end,

        powershell_es = function()
            local lspconfig = require("lspconfig")
            lspconfig.powershell_es.setup({
                bundle_path = "~/.local/share/nvim/PowerShellEditorServices",
                on_attach = on_attach,
                init_options = {
                    enableProfileLoading = false,
                },
                -- Found these setting on: https://github.com/PowerShell/PowerShellEditorServices/blob/main/src/PowerShellEditorServices/Services/Workspace/LanguageServerSettings.cs#L168
                settings = {
                    powershell = {
                        scriptAnalysis = {
                            enable = true,
                        },
                        codeFormatting = {
                            Preset = "Allman",
                            openBraceOnSameLine = false,
                            addWhitespaceAroundPipe = true,
                            useCorrectCasing = true,
                            alignPropertyValuePairs = true,
                            useConstantStrings = true,
                        },
                    },
                },
            })
        end,
    },
})

-- LUA ----------------------------------------------------------------
lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = {
                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                    [vim.fn.stdpath("config") .. "/lua"] = true,
                },
            },
            telemetry = {
                enable = false,
            },
        },
    },
})

-- Ansible ------------------------------------------------------------
lspconfig.ansiblels.setup({
    ansible = {
        ansible = {
            path = "ansible",
        },
        executionEnvironment = {
            enabled = false,
        },
        python = {
            interpreterPath = "python",
        },
        validation = {
            enabled = true,
            lint = {
                enabled = true,
                path = "ansible-lint",
            },
        },
    },
})

-- Mardown ------------------------------------------------------------
lspconfig.marksman.setup({})

local configs = require("lspconfig/configs")
configs.zk = {
    default_config = {
        cmd = { "zk", "lsp" },
        filetypes = { "markdown" },
        root_dir = function()
            lspconfig.util.root_pattern(".zk")
            -- return vim.loop.cwd()
        end,
        settings = {},
    },
}

lspconfig.zk.setup({
    on_attach = function(client, bufnr)
        -- Key mappings
        local function buf_set_keymap(...)
            vim.api.nvim_buf_set_keymap(bufnr, ...)
        end
        local opts = { noremap = true, silent = true }
        buf_set_keymap("n", "<CR>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
        buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
        buf_set_keymap("n", "<leader>zi", ":ZkIndex<CR>", opts)
        buf_set_keymap("v", "<leader>zn", ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)
        buf_set_keymap("n", "<leader>zn", ":ZkNew {title = vim.fn.input('Title: ')}<CR>", opts)
        buf_set_keymap("n", "<leader>zl", ":ZkNew {dir = 'log'}<CR>", opts)
    end,
}) -- Add keybindings here, see https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
local cmp_select = { behavior = cmp.SelectBehavior.Replace }

cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(cmp_select), { "i" }),
        ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(cmp_select), { "i" }),
        ["<C-S-f>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<C-l>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        }),
        ["<C-Space>"] = cmp.mapping.complete(),
    }),
    sources = cmp.config.sources({
        { name = "path" }, -- file paths
        { name = "nvim_lsp", keyword_length = 3 }, -- from language server
        { name = "nvim_lsp_signature_help" }, -- display function signatures with current parameter emphasized
        { name = "nvim_lua", keyword_length = 2 }, -- complete neovim's Lua runtime API such vim.lsp.*
        { name = "buffer", keyword_length = 2 }, -- source current buffer
        { name = "vsnip", keyword_length = 2 }, -- nvim-cmp source for vim-vsnip
        { name = "calc" }, -- source for math calculation,
    }),
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    formatting = {
        fields = { "menu", "abbr", "kind" },
        format = function(entry, item)
            local menu_icon = {
                nvim_lsp = "λ",
                vsnip = "⋗",
                buffer = "Ω",
                path = "🖫",
            }
            item.menu = menu_icon[entry.source.name]
            return item
        end,
    },
    opts = {
        capabilities = {
            textDocument = {
                foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true,
                },
            },
        },
    },
})

-- C Sharp ----------------------------------------------------------------
require("lspconfig").omnisharp.setup({
    cmd = { "dotnet", "/opt/homebrew/bin/omnisharp" },

    settings = {
        FormattingOptions = {
            -- Enables support for reading code style, naming convention and analyzer
            -- settings from .editorconfig.
            EnableEditorConfigSupport = true,
            -- Specifies whether 'using' directives should be grouped and sorted during
            -- document formatting.
            OrganizeImports = true,
        },
        MsBuild = {
            -- If true, MSBuild project system will only load projects for files that
            -- were opened in the editor. This setting is useful for big C# codebases
            -- and allows for faster initialization of code navigation features only
            -- for projects that are relevant to code that is being edited. With this
            -- setting enabled OmniSharp may load fewer projects and may thus display
            -- incomplete reference lists for symbols.
            LoadProjectsOnDemand = nil,
        },
        RoslynExtensionsOptions = {
            -- Enables support for roslyn analyzers, code fixes and rulesets.
            EnableAnalyzersSupport = nil,
            -- Enables support for showing unimported types and unimported extension
            -- methods in completion lists. When committed, the appropriate using
            -- directive will be added at the top of the current file. This option can
            -- have a negative impact on initial completion responsiveness,
            -- particularly for the first few completion sessions after opening a
            -- solution.
            EnableImportCompletion = nil,
            -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
            -- true
            AnalyzeOpenDocumentsOnly = nil,
        },
        Sdk = {
            -- Specifies whether to include preview versions of the .NET SDK when
            -- determining which version to use for project loading.
            IncludePrereleases = true,
        },
    },
})
-- Formatting ----------------------------------------------------------------
-- Change border of documentation hover window
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
})

-- Diagnostic ----------------------------------------------------------------
vim.diagnostic.config({
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})
