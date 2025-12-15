-- [[ Telescope Overview ]]
--
-- Telescope is an extensible fuzzy finder for Neovim. A great way to explore it is:
--
--     :Telescope help_tags
--
-- Inside any Telescope picker, two discovery keymaps are invaluable:
--
--   • Insert mode: <C-/>   — Show all keymaps for the current picker
--   • Normal mode: ?       — Same as above, but from normal mode
--
-- These help you learn available actions and picker‑specific shortcuts.

-- [[ Configure Telescope ]]
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local themes = require("telescope.themes")

-- Reusable theme helper
local dropdown_no_preview = themes.get_dropdown({
    winblend = 10,
    previewer = false,
})

require("telescope").setup({
    defaults = {
        path_display = { "truncate" },
        dynamic_preview_title = true,

        mappings = {
            i = {
                -- Copy selected line to clipboard and return to previous buffer
                ["<C-y>"] = function(prompt_bufnr)
                    local entry = action_state.get_selected_entry()
                    local line = entry.text
                    vim.fn.setreg("+", line)
                    actions.close(prompt_bufnr)
                    vim.cmd("b#")
                end,

                -- Insert selected line into buffer
                ["<C-i>"] = function(prompt_bufnr)
                    local entry = action_state.get_selected_entry()
                    local line = entry.text
                    actions.close(prompt_bufnr)
                    vim.api.nvim_put({ line }, "", true, true)
                end,
            },

            n = {
                ["<C-y>"] = function(prompt_bufnr)
                    local entry = action_state.get_selected_entry()
                    local line = entry.text
                    vim.fn.setreg("+", line)
                    actions.close(prompt_bufnr)
                    vim.cmd("b#")
                end,
            },
        },
    },

    pickers = {
        find_files = {
            theme = "ivy",
            sorting_strategy = "ascending",
        },
    },

    extensions = {
        ["ui-select"] = themes.get_dropdown(),
        fzf = {},
    },
})

-- Load extensions safely
pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")
pcall(require("telescope").load_extension, "live_grep_args")

-- [[ Keymaps ]]
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]elect Telescope Picker" })
vim.keymap.set("n", "<leader>sm", builtin.lsp_document_symbols, { desc = "[S]earch [M]ethod Symbols in this file" })
vim.keymap.set(
    "n",
    "<leader>sM",
    builtin.lsp_workspace_symbols,
    { desc = "[S]earch Workspace [M]ethod Symbols in this file" }
)
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

-- Fuzzy search in current buffer
vim.keymap.set("n", "<leader>/", function()
    builtin.current_buffer_fuzzy_find(dropdown_no_preview)
end, { desc = "[/] Search in current buffer" })

-- Live grep in open files only
vim.keymap.set("n", "<leader>s/", function()
    builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
    })
end, { desc = "[S]earch [/] in Open Files" })

-- Search Neovim config
vim.keymap.set("n", "<leader>sn", function()
    builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

-- Fuzzy search current buffer (duplicate of <leader>/ but kept for your workflow)
vim.keymap.set("n", "<C-y>", function()
    builtin.current_buffer_fuzzy_find(dropdown_no_preview)
end, { desc = "Fuzzy search buffer" })

-- Highlighting tweaks
vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = "white", bg = "#182931" })
vim.api.nvim_set_hl(0, "TelescopePreviewLine", { fg = "black", bg = "#DAAE6B" })

-- [[ Multi-Grep using live_grep_args ]]
vim.keymap.set("n", "<leader>sg", function()
    require("telescope").extensions.live_grep_args.live_grep_args()
end, { desc = "[S]earch by [G]rep (args)" })
