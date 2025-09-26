require("keytrail").setup({
    -- The delimiter to use between path segments
    delimiter = ".",
    -- The delay in milliseconds before showing the hover popup
    hover_delay = 100,
    -- The key mapping to use for jumping to a path
    key_mapping = "jq",
    -- The file types to enable KeyTrail for
    filetypes = {
        yaml = true,
        json = true,
    },
})
