local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

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
    -- Signature help customization
    vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
        if err or not result or not result.signatures or #result.signatures == 0 then
            return
        end
        vim.lsp.handlers["textDocument/signatureHelp"](err, result, ctx, config)
    end
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "single", -- Options: "single", "double", "rounded", "solid", "shadow"
        max_width = 80,
        max_height = 20,
        focusable = false,
    })
end

return {
    on_attach = on_attach,
    capabilities = capabilities,
    on_init = function(client, _)
        client.server_capabilities.semanticTokensProvider = true
    end,
}
