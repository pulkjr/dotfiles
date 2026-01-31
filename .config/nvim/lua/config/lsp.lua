-- LSP info in lower right corner
require("fidget").setup({})

-- ENABLE LSPs----------------------------------------------------------------
vim.lsp.enable({
    "ansiblels",
    "lemminx",
    "lua_ls",
    "marksman",
    "powershell_es",
    "roslyn",
    "rust_analyzer",
    "zk",
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
    -- virtual_text = {
    --     prefix = "●", -- You can change this to any icon or string you prefer
    --     spacing = 4, -- Adjust the spacing between the text and the diagnostic message
    -- },
    virtual_lines = true,
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
