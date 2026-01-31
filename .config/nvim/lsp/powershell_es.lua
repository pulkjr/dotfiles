local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

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
    -- on_attach = on_attach,
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
