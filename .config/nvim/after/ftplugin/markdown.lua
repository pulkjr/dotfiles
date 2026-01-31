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

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft == "markdown" then
            vim.keymap.set(
                "n",
                "gd",
                function()
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
                end,
                { desc = "Go to Markdown link (decoded + resolved)", buffer = args.buf, noremap = true, silent = true }
            )
        end
    end,
})

-- Add the key mappings only for Markdown files in a zk notebook.
if require("zk.util").notebook_root(vim.fn.expand("%:p")) ~= nil then
    local function get_group_dir(template)
        if template == "azure.md" then
            return vim.fn.expand("~/git/Personal/dailyZK/azure")
        elseif template == "map.md" then
            return vim.fn.expand("~/git/Personal/dailyZK/maps")
        else
            return vim.fn.expand("%:p:h")
        end
    end

    local function map(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = true
        opts.silent = true
        opts.noremap = true
        vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Open the link under the caret.
    map("n", "<CR>", "<Cmd>lua vim.lsp.buf.definition()<CR>")

    -- Create a new note after asking for its title.
    -- This overrides the global `<leader>zn` mapping to create the note in the same directory as the current buffer.
    map("n", "<leader>zn", function()
        local title = vim.fn.input("New Note Title: ")

        -- Cancel if user presses ESC or enters nothing
        if not title or title == "" then
            print("Note creation cancelled")
            return
        end

        require("zk.commands").get("ZkNew")({
            dir = vim.fn.expand("%:p:h"),
            title = title,
        })
    end, { desc = "[Z]k Create [N]ew note in current directory" })

    -- Create a new note in the same directory as the current buffer, using the current selection for title.
    map("v", "<leader>znt", function()
        require("zk.commands").get("ZkNewFromTitleSelection")({ dir = vim.fn.expand("%:p:h") })
    end, { desc = "[Z]k Create [N]ew [T]itle note in current directory" })

    -- Create a new note in the same directory as the current buffer, using the current selection for note content and asking for its title.
    map("v", "<leader>znc", function()
        local title = vim.fn.input("New Note Title: ")

        -- Cancel if user presses ESC or enters nothing
        if not title or title == "" then
            print("Note creation cancelled")
            return
        end

        require("zk.commands").get("ZkNewFromContentSelection")({
            dir = vim.fn.expand("%:p:h"),
            title = title,
        })
    end, { desc = "[Z]k Create [N]ew [C]ontent note in current directory" })

    -- Open notes linking to the current buffer.
    map("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", { desc = "[Z]k [B]acklinks" })
    -- Alternative for backlinks using pure LSP and showing the source context.
    --map('n', '<leader>zb', '<Cmd>lua vim.lsp.buf.references()<CR>')
    -- Open notes linked by the current buffer.
    map("n", "<leader>zl", "<Cmd>ZkLinks<CR>", { desc = "[Z]k [L]inks" })

    -- Preview a linked note.
    map("n", "K", vim.lsp.buf.hover)

    -- Open the code actions for a visual selection.
    map("v", "<leader>za", vim.lsp.buf.code_action, { desc = "[Z]k [A]ctions" })

    ---------------------------------------------------------------------------
    -- SMART NEW NOTE template picker + wikilink + backlink + group directory
    ---------------------------------------------------------------------------
    map("n", "<leader>zm", function()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        local templates = { "azure.md", "map.md", "default.md" }

        pickers
            .new({}, {
                prompt_title = "Select Template",
                finder = finders.new_table(templates),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, lmap)
                    actions.select_default:replace(function()
                        local template = action_state.get_selected_entry()[1]
                        actions.close(prompt_bufnr)

                        -- Ask for title
                        local title = vim.fn.input("Title: ")

                        -- Determine directory based on template
                        local dir = get_group_dir(template)

                        -- Insert wikilink in current note
                        local link = string.format("[[%s]]", title)
                        vim.api.nvim_put({ link }, "c", true, true)

                        -- Get current note title for backlink
                        local current_title = vim.fn.expand("%:t:r")

                        -- Create the new note (Lua call, NOT a string)
                        require("zk.commands").get("ZkNew")({
                            title = title,
                            template = template, -- "azure.md", "map.md", etc.
                            dir = dir,
                            -- callback = function(err, note)
                            --     if err then
                            --         print("Error creating note:", err)
                            --         return
                            --     end
                            --
                            --     -- Open the new note
                            --     vim.cmd("edit " .. note.path)
                            --
                            --     -- Insert backlink at top
                            --     local backlink = string.format("[[%s]]", current_title)
                            --     vim.api.nvim_buf_set_lines(0, 0, 0, false, { backlink, "" })
                            -- end,
                        })
                    end)
                    return true
                end,
            })
            :find()
    end, { desc = "[Z]k [M]ake new note with template and backlinks" })
end
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
