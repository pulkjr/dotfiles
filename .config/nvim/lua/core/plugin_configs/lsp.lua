local cmp = require('cmp')
local cmp_lsp = require('cmp_nvim_lsp')
local capabilities = vim.tbl_deep_extend(
    'force',
    {},
    vim.lsp.protocol.make_client_capabilities(),
    cmp_lsp.default_capabilities())

require('fidget').setup({})
require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = {},
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup {
                capabilities = capabilities
            }
        end,

        powershell_es = function()
            local lspconfig = require('lspconfig')
            lspconfig.powershell_es.setup{
                bundle_path = '~/.config/nvim/customLsp',
                on_attach = function(client, bufnr)
                    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
                end,
                settings = {powershell = { codeFormatting = { Preset = 'OTBS'} } }
            }
        end
    }
})

require("lspconfig").lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.stdpath "config" .. "/lua"] = true,
        },
      },
    },
  }
}

require('lspconfig').ansiblels.setup {
    ansible = {
        ansible = {
            path = "ansible"
        },
        executionEnvironment = {
            enabled = false
        },
        python = {
            interpreterPath = "python"
        },
        validation = {
            enabled = true,
            lint = {
                enabled = true,
                path = "ansible-lint"
            }
        }
    }
}

require('lspconfig').marksman.setup {}

local cmp_select = { behavior = cmp.SelectBehavior.Replace }

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(cmp_select), {'i'}),
        ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(cmp_select), {'i'}),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
            { name = 'buffer' },
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
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})
