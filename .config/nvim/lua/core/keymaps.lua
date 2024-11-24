vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local k = vim.keymap

--Open ntrw
k.set("n", "<leader>pv", vim.cmd.Ex)

-- Yank to system clipboard
k.set("v", "<leader>y", '"*y', { desc = 'Yank to System Clipboard' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
k.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
k.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Disable arrow keys in normal mode
k.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
k.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
k.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
k.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- new tab
k.set('n', '<leader>ac', '<cmd>tabnew<CR>', { desc = 'Create a new tab' })
k.set('n', '<leader>an', '<cmd>tabNext<CR>', { desc = 'Move to next tab' })
k.set('n', '<leader>ap', '<cmd>tabprevious<CR>', { desc = 'Move to previous tab' })

-- Open notes.
vim.api.nvim_set_keymap("n", "<leader>zo", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>",
    { noremap = true, silent = false })

-- Todo
k.set("n", "]t", function()
    require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

k.set("n", "[t", function()
    require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

k.set('n', '<leader>st', function()
    vim.cmd('TodoTelescope cwd=~/git/Personal/dailyZK')
end, { desc = 'Find Search Todo Items in Zk' })

-- Formatting
k.set({ "n", "v" }, "<leader>f", function()
    require('conform').format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
    })
end, { desc = "Format file or range (in visual mode)" })
