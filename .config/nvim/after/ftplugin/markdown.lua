-- local currDir = vim.fn.expand('%:p')
-- local pattern = 'dailyZK'

vim.opt.spell = true
vim.opt.spelllang = "en_us"

vim.api.nvim_create_user_command("EncodeMarkdownLinks", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    for i, line in ipairs(lines) do
        lines[i] = line:gsub("%[(.-)%]%(%s*<?(.-)>?%s*%)", function(text, url)
            local encoded = url:gsub(" ", "%%20")
            return string.format("[%s](%s)", text, encoded)
        end)
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end, {})

-- Create an autocommand that triggers before a buffer is written to disk
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.md",
    callback = function()
        -- Save current cursor position (row, col)
        local pos = vim.api.nvim_win_get_cursor(0)

        -- Perform substitutions
        vim.cmd([[silent! %s/—/-/ge]]) -- em dash (—) to ASCII dash (-)
        vim.cmd([[silent! %s/–/-/ge]]) -- en dash (–) to ASCII dash (-)
        vim.cmd([[silent! %s/’/'/ge]]) -- smart apostrophe (’) to ASCII apostrophe (')
        vim.cmd([[silent! %s/[“”]/"/ge]]) -- smart double quotes (“ ”) to ASCII double quote (")
        vim.cmd([[silent! %s/…/.../ge]]) -- ellipsis (…) to three dots (...)

        -- Restore cursor position
        pcall(vim.api.nvim_win_set_cursor, 0, pos)
    end,
})

vim.keymap.set("n", "gd", function()
    local line = vim.api.nvim_get_current_line()
    local cursor_col = vim.fn.col(".")
    local found = false

    for text, raw_url in line:gmatch("%[(.-)%]%(%s*<?(.-)>?%s*%)") do
        local full_match = string.format("[%s](%s)", text, raw_url)
        local start_pos = line:find(full_match, 1, true)
        if start_pos then
            local end_pos = start_pos + #full_match - 1
            if cursor_col >= start_pos and cursor_col <= end_pos then
                -- Decode and clean the URL
                local decoded = raw_url:gsub("%%20", " "):gsub("^%s*<", ""):gsub(">%s*$", "")

                -- Resolve relative to current buffer
                local current_file = vim.api.nvim_buf_get_name(0)
                local current_dir = vim.fn.fnamemodify(current_file, ":h")
                local full_path = vim.fn.fnamemodify(current_dir .. "/" .. decoded, ":p")

                vim.cmd("edit " .. full_path)
                found = true
                break
            end
        end
    end

    if not found then
        print("No Markdown link found under cursor.")
    end
end, { desc = "Go to Markdown link (decoded + resolved)", noremap = true, silent = true })

-- Add the key mappings only for Markdown files in a zk notebook.
-- if require("zk.util").notebook_root(vim.fn.expand("%:p")) ~= nil then
--     local function map(...)
--         vim.api.nvim_buf_set_keymap(0, ...)
--     end
--     local opts = { noremap = true, silent = false }
--
--     -- Open the link under the caret.
--     map("n", "<CR>", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
--
--     -- Create a new note after asking for its title.
--     -- This overrides the global `<leader>zn` mapping to create the note in the same directory as the current buffer.
--     map("n", "<leader>zn", "<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>", opts)
--     -- Create a new note in the same directory as the current buffer, using the current selection for title.
--     map("v", "<leader>znt", ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>", opts)
--     -- Create a new note in the same directory as the current buffer, using the current selection for note content and asking for its title.
--     map(
--         "v",
--         "<leader>znc",
--         ":'<,'>ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
--         opts
--     )
--
--     -- Open notes linking to the current buffer.
--     map("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", opts)
--     -- Alternative for backlinks using pure LSP and showing the source context.
--     --map('n', '<leader>zb', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
--     -- Open notes linked by the current buffer.
--     map("n", "<leader>zl", "<Cmd>ZkLinks<CR>", opts)
--
--     -- Preview a linked note.
--     map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
--     -- Open the code actions for a visual selection.
--     map("v", "<leader>za", ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)
-- end
--
-- COLORS ----------------------------------------------------------------------------------------

-- local color_fg = "#0D1116"
-- local color_bg1 = "#987afb"
-- local color_bg2 = "#37f499"
-- local color_bg3 = "#04d1f9"
-- local color_bg4 = "#949ae5"
--
-- vim.cmd(
--     string.format([[highlight @markup.heading.1.markdown cterm=bold gui=bold guifg=%s guibg=%s]], color_fg, color_bg1)
-- )
-- vim.cmd(
--     string.format([[highlight @markup.heading.2.markdown cterm=bold gui=bold guifg=%s guibg=%s]], color_fg, color_bg2)
-- )
-- vim.cmd(
--     string.format([[highlight @markup.heading.3.markdown cterm=bold gui=bold guifg=%s guibg=%s]], color_fg, color_bg3)
-- )
-- vim.cmd(
--     string.format([[highlight @markup.heading.4.markdown cterm=bold gui=bold guifg=%s guibg=%s]], color_fg, color_bg4)
-- )
vim.cmd('syntax match nonascii "[^\\x00-\\x7F]"')
vim.cmd("highlight nonascii guibg=Red ctermbg=2")
