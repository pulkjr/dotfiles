require("onedark").setup({
    style = "deep",
    highlights = {
        CursorLine = {
            bg = "#101010",
        },
        -- ["@lsp.type.property"] = {
        --     fg = "#00A1F7",
        -- },
    },
    toggle_style_key = "<leader>ts", -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
    code_style = {
        comments = "italic",
        keywords = "none",
        functions = "bold",
        strings = "none",
        variables = "none",
    },
})
require("onedark").load()
