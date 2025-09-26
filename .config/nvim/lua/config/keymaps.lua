vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local k = vim.keymap

--Open ntrw
k.set("n", "<leader>pv", vim.cmd.Ex)
k.set("n", "-", vim.cmd.Ex)

-- Yank to system clipboard
k.set("v", "<leader>y", '"*y', { desc = "Yank to System Clipboard" })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
k.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
k.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
k.set("n", "<leader>qr", function()
    require("telescope.builtin").quickfix()
end, { desc = "Open diagnostic [Q]uickfix list with Telescope" })

-- Disable arrow keys in normal mode
k.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
k.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
k.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
k.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- new tab
k.set("n", "<leader>ac", "<cmd>tabnew<CR>", { desc = "Create a new tab" })
k.set("n", "<leader>an", "<cmd>tabNext<CR>", { desc = "Move to next tab" })
k.set("n", "<leader>ap", "<cmd>tabprevious<CR>", { desc = "Move to previous tab" })

-- Open Zettlekasten Note
k.set("n", "<leader>zo", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", { desc = "[Z]k [O]pen a note" })

-- Todo
k.set("n", "]t", function()
    require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

k.set("n", "[t", function()
    require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- Formatting
k.set({ "n", "v" }, "<leader>f", function()
    require("conform").format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
    })
end, { desc = "[F]ormat file or range (in visual mode)" })

-- Toggle line wrap using vscode style keymap
k.set("n", "<A-z>", function()
    vim.notify(string.format("%s wrap", vim.o.wrap and "Enabling" or "Disabling"), vim.log.levels.INFO)

    vim.o.wrap = not vim.o.wrap
end, { desc = "Enable word wrap" })

--LSP
k.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename the ficture under cursour" })

--LSPSaga
k.set("n", "<leader>o", ":Lspsaga outline<CR>", { desc = "Open the outline for the given file" })

k.set("n", "<leader>st", function()
    local current = vim.wo.signcolumn
    vim.wo.signcolumn = (current == "yes") and "no" or "yes"
end, { desc = "Toggle sign column" })
