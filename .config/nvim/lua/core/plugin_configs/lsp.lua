local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")
local capabilities =
    vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), cmp_lsp.default_capabilities())

local lspconfig = require("lspconfig")

local on_attach = function(client, bufnr)
    -- Key mappings
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local opts = { noremap = true, silent = true }
    buf_set_keymap("n", "gD", "<cmd>Telescope lsp_type_definitions<CR>", opts)
    buf_set_keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
    buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap("n", "gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
    buf_set_keymap("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
    buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    -- buf_set_keymap("n", "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", opts)
    -- buf_set_keymap("n", "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
end

require("fidget").setup({})
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {},
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
                on_attach = on_attach_ps,
                init_options = {
                    enableProfileLoading = false,
                },
                settings = { powershell = { codeFormatting = { Preset = "OTBS" } } },
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
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
    }, {
        { name = "buffer" },
    }),
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
