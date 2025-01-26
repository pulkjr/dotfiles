---Test if a file exists on the file system
---@param filePath any
---@return boolean
local function file_exists(filePath)
    local f = io.open(filePath, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

local function open_file(filePath)
    vim.cmd(string.format("edit %s", filePath))
end
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local k = vim.keymap
local zkPath = vim.fn.expand("$HOME/git/Personal/dailyZK")
--Open ntrw
k.set("n", "<leader>pv", vim.cmd.Ex)

-- Yank to system clipboard
k.set("v", "<leader>y", '"*y', { desc = "Yank to System Clipboard" })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
k.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
k.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Disable arrow keys in normal mode
k.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
k.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
k.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
k.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- new tab
k.set("n", "<leader>ac", "<cmd>tabnew<CR>", { desc = "Create a new tab" })
k.set("n", "<leader>an", "<cmd>tabNext<CR>", { desc = "Move to next tab" })
k.set("n", "<leader>ap", "<cmd>tabprevious<CR>", { desc = "Move to previous tab" })

-- Open notes.
vim.api.nvim_set_keymap(
    "n",
    "<leader>zo",
    "<Cmd>ZkNotes { sort = { 'modified' } }<CR>",
    { noremap = true, silent = false }
)

k.set("n", "<leader>t", function()
    local monthNotePath = string.format("%s/journal/todo/%s", zkPath, os.date("%Y-%m.md"))
    local lastMonthPath =
        string.format("%s/journal/todo/%s", zkPath, os.date("%Y-%m.md", os.time() - 31 * 24 * 60 * 60))

    if file_exists(monthNotePath) then
        open_file(monthNotePath)
    elseif file_exists(lastMonthPath) then
        os.execute(string.format("cp %1 %2", monthNotePath, lastMonthPath))
        open_file(lastMonthPath)
    else
        print("Previous File missing: " .. lastMonthPath)
    end
end, { desc = "Open [T]odays Zk" })

k.set("n", "<leader>st", function()
    vim.cmd(string.format("TodoTelescope cwd=%1", zkPath))
end, { desc = "Find [S]earch [T]odo Items in Zk" })

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
        timeout_ms = 500,
    })
end, { desc = "Format file or range (in visual mode)" })

k.set("n", "<M-z>", function()
    if vim.opt.wrap then
        vim.opt.wrap = false
    else
        vim.opt.wrap = true
    end
end, { desc = "Enable word wrap" })

--LSP
k.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename the ficture under cursour" })
