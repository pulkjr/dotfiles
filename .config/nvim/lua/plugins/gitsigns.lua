require("gitsigns").setup({
    signs = {
        add = { text = "+" }, -- Symbol for added lines
        change = { text = "~" }, -- Symbol for changed lines
        delete = { text = "_" }, -- Symbol for deleted lines
        topdelete = { text = "‾" }, -- Symbol for top-line deletions
        changedelete = { text = "~" }, -- Symbol for lines that were changed and then deleted
        untracked = { text = "┆" }, -- Symbol for untracked lines
    },
    signs_staged = {
        add = { text = "┃" }, -- Symbol for staged additions
        change = { text = "┃" }, -- Symbol for staged changes
        delete = { text = "_" }, -- Symbol for staged deletions
        topdelete = { text = "‾" }, -- Symbol for staged top-line deletions
        changedelete = { text = "~" }, -- Symbol for staged change-deletes
        untracked = { text = "┆" }, -- Symbol for staged untracked lines
    },
    signs_staged_enable = true, -- Enable separate symbols for staged changes
    signcolumn = true, -- Show signs in the sign column
    numhl = true, -- Highlight line numbers for changed lines
    linehl = false, -- Highlight entire lines for changes
    word_diff = false, -- Highlight word-level diffs within changed lines
    watch_gitdir = {
        follow_files = true, -- Watch files even if they are moved or renamed
    },
    auto_attach = true, -- Automatically attach to buffers when opened
    attach_to_untracked = false, -- Don't attach to untracked files
    current_line_blame = true, -- Show git blame info for the current line
    current_line_blame_opts = {
        virt_text = true, -- Display blame info as virtual text
        virt_text_pos = "eol", -- Position blame text at end of line
        delay = 1000, -- Delay before showing blame (in ms)
        ignore_whitespace = true, -- Ignore whitespace when blaming
        virt_text_priority = 100, -- Priority of virtual text display
        use_focus = true, -- Only show blame when buffer is focused
    },
    current_line_blame_formatter = "<author>, <author_time:%R> - <summary>", -- Format of blame text
    sign_priority = 6, -- Priority of signs (higher = more visible)
    update_debounce = 100, -- Delay before updating signs after changes (in ms)
    status_formatter = nil, -- Use default status line formatter
    max_file_length = 40000, -- Disable plugin for files longer than this (in lines)
    preview_config = {
        border = "single", -- Border style for preview window
        style = "minimal", -- Minimal style (no padding or decorations)
        relative = "cursor", -- Position preview window relative to cursor
        row = 0, -- Row offset from cursor
        col = 1, -- Column offset from cursor
    },
})
vim.keymap.set("n", "<leader>gw", function()
    local gs = require("gitsigns")
    gs.toggle_word_diff()
end, { desc = "Toggle GitSigns word diff" })
