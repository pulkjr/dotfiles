local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local M = {}

local live_multigrep = function(opts)
    opts = opts or {}

    -- Use current working directory instead of relying on Git
    local git_ok, _ = pcall(vim.cmd, ":Gcd")

    if not git_ok then
        opts.cwd = vim.fn.getcwd() -- Use current directory if Git fails
    end

    local finder = finders.new_async_job({
        command_generator = function(prompt)
            if not prompt or prompt == "" then
                return nil
            end

            local pieces = vim.split(prompt, "  ")
            local args = { "rg" }
            if pieces[1] then
                table.insert(args, "-e")
                table.insert(args, pieces[1])
            end

            if pieces[2] then
                table.insert(args, "-g")
                table.insert(args, pieces[2])
            end

            return vim.tbl_flatten({
                args,
                { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
            })
        end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd or vim.fn.getcwd(), -- Ensure search runs in current dir
    })
    pickers
        .new(opts, {
            debounce = 100,
            prompt_title = "Muli Grep",
            finder = finder,
            previewer = conf.grep_previewer(opts),
            sorter = require("telescope.sorters").empty(),
        })
        :find()
end

M.setup = function()
    vim.keymap.set("n", "<leader>sg", live_multigrep)
end

return M
