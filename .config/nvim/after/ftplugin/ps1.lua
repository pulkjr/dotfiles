print("PowerShell File Config")

-- vim.api.nvim_set_hl(0, "@variable.powershell", { fg = variable_color })
-- vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = variable_color })
--
-- vim.api.nvim_create_autocmd("LspAttach", {
--     callback = function(args)
--         local client = vim.lsp.get_client_by_id(args.data.client_id)
--         client.server_capabilities.semanticTokensProvider = nil
--         print("LspAttach")
--     end,
-- })
--
-- local function show_def_variable(args)
--     local token = args.data.token
--     if token.type ~= "variable" or token.modifiers.readonly then
--         return
--     end
--
--     local text = vim.api.nvim_buf_get_text(args.buf, token.line, token.start_col, token.line, token.end_col, {})[1]
--
--     if text ~= string.upper(text) then
--         return
--     end
--
--     vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, "Error")
-- end
--
-- vim.api.nvim_create_autocmd("LspTokenUpdate", {
--     callback = show_def_variable,
-- })

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "powershell_es" then
            client.server_capabilities.semanticTokensProvider = nil
        end
    end,
})
