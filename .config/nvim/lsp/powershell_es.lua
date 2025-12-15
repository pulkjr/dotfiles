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
end

local default_formatting = {
    -- Preset = "Allman",
    openBraceOnSameLine = false,
    addWhitespaceAroundPipe = true,
    useCorrectCasing = true,
    alignPropertyValuePairs = true,
    useConstantStrings = true,
}

local settings_path = vim.fn.getcwd() .. "/.vscode/settings.json"
local merged_formatting = vim.deepcopy(default_formatting)

if vim.fn.filereadable(settings_path) == 1 then
    local content = table.concat(vim.fn.readfile(settings_path), "\n")
    local ok, parsed = pcall(vim.fn.json_decode, content)

    if ok and type(parsed) == "table" then
        for key, value in pairs(parsed) do
            local prefix = "powershell.codeFormatting."
            if key:sub(1, #prefix) == prefix then
                local setting_name = key:sub(#prefix + 1)
                merged_formatting[setting_name] = value
            end
        end
    end
end

return {
    bundle_path = "~/.local/share/nvim/PowerShellEditorServices",
    on_attach = on_attach,
    capabilities = capabilities,
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
            codeFormatting = merged_formatting,
        },
    },
    float = { border = "rounded" },
}
