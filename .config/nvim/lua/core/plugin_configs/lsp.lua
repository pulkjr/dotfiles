local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")
local capabilities =
    vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), cmp_lsp.default_capabilities())

local lspconfig = require("lspconfig")

local on_attach = function(client, bufnr)
    -- Key mappings
    local k = vim.keymap

    -- Disable LSP Token highlight. Need to figure out how to only do this for PowerShell
    -- client.server_capabilities.semanticTokensProvider = nil

    local opts = { noremap = true, silent = true, buffer = bufnr }

    k.set("n", "gD", "<cmd>Telescope lsp_type_definitions<CR>", opts)
    k.set("n", "gd", vim.lsp.buf.definition, opts)
    k.set("n", "gn", vim.lsp.buf.rename, opts)
    k.set("n", "K", vim.lsp.buf.hover, opts)
    k.set("n", "gh", vim.lsp.buf.signature_help, opts)
    k.set("n", "gi", vim.lsp.buf.implementation, opts)
    k.set("n", "gr", vim.lsp.buf.references, opts)
    k.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    k.set("n", "[d", vim.diagnostic.goto_prev, opts)
    k.set("n", "]d", vim.diagnostic.goto_next, opts)
    k.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    k.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    k.set("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    k.set("n", "<leader>r", vim.lsp.buf.rename, opts)
    k.set("i", "<C-Space>", vim.lsp.buf.completion, opts)
end

require("fidget").setup({})
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "marksman",
        "lua_ls",
    },
})

-- PowerShell ------------------------------------------------------------
vim.lsp.config.powershell_es = {
    bundle_path = "~/.local/share/nvim/PowerShellEditorServices",
    on_attach = on_attach,
    init_options = {
        enableProfileLoading = false,
    },
    -- Found these setting on: https://github.com/PowerShell/PowerShellEditorServices/blob/main/src/PowerShellEditorServices/Services/Workspace/LanguageServerSettings.cs#L168
    settings = {
        powershell = {
            scriptAnalysis = {
                enable = true, -- Enables ScriptAnalysis
                settingsPath = "~/.config/powershell/MyPSScriptAnalyzerRules.psd1",
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
    float = { border = "rounded" },
}
vim.lsp.enable("powershell_es")
-- LUA ----------------------------------------------------------------
vim.lsp.config.lua_ls = {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT", -- Neovim uses LuaJIT
            },
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
}
vim.lsp.enable("lua_ls")

-- C Sharp ----------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
    pattern = "cs", -- Ensure it only applies to C# files
    callback = function()
        vim.lsp.start({
            name = "omnisharp",
            cmd = { "omnisharp" }, -- Ensure OmniSharp is installed and accessible
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
            on_init = function(client, _)
                print("OmniSharp LSP started!") -- Debugging
            end,
            settings = {
                omnisharp = {
                    enable_roslyn_analyzers = true,
                    analyze_open_documents_only = false,
                    organize_imports_on_format = true,
                    enable_import_completion = true,
                    exclude_project_directories = { "node_modules", "bin", "obj" },
                },
            },
        })
    end,
})

-- Ansible ------------------------------------------------------------
vim.lsp.config.ansiblels = {
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
}
vim.lsp.enable("ansiblels")

-- Mardown ------------------------------------------------------------
vim.lsp.config.marksman = {}
vim.lsp.enable("marksman")

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
        { name = "nvim_lsp", keyword_length = 3 }, -- from language server
        { name = "buffer", keyword_length = 2 }, -- source current buffer
        { name = "path" }, -- file paths
        { name = "luasnip" }, -- file paths
        { name = "nvim_lsp_signature_help" }, -- display function signatures with current parameter emphasized
        { name = "nvim_lua", keyword_length = 2 }, -- complete neovim's Lua runtime API such vim.lsp.*
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

-- Formatting ----------------------------------------------------------------
-- Change border of documentation hover window
vim.ui.open_floating_window = function(contents, opts)
    opts.border = "rounded" -- Ensure all LSP floating windows have rounded borders
    return vim.lsp.util.open_floating_preview(contents, opts)
end

-- Diagnostic ----------------------------------------------------------------
vim.diagnostic.config({
    -- Enable virtual text (inline diagnostics)
    virtual_text = {
        prefix = "●", -- You can change this to any icon or string you prefer
        spacing = 4, -- Adjust the spacing between the text and the diagnostic message
    },
    signs = true, -- Show diagnostic signs in the sign column
    underline = true, -- Underline the affected code
    update_in_insert = false, -- Update diagnostics when you leave insert mode (set to true if you prefer live updates)
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})
