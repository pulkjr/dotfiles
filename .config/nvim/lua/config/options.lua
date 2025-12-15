local opt = vim.opt

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- INDENTATION & FORMATTING --------------------------------------------------
vim.opt.tabstop = 4 -- Sets the width of a tab character (4 spaces)
vim.opt.shiftwidth = 4 -- Defines indentation width when using '>>' or '<<' commands (4 spaces)
vim.opt.softtabstop = 4 -- Controls the number of spaces inserted when pressing Tab (4 spaces)
vim.opt.expandtab = true -- Converts tabs into spaces when pressing Tab
vim.opt.smartindent = true -- Enables smart auto-indentation based on syntax rules
vim.opt.wrap = false -- Disables line wrapping; lines continue horizontally without breaking

-- SEARCH --------------------------------------------------------------------
vim.opt.incsearch = true -- Enables incremental search (highlights matches as you type)
vim.opt.ignorecase = true -- Makes search case-insensitive
vim.opt.smartcase = true -- Overrides 'ignorecase' if uppercase letters are used in the search
vim.opt.hlsearch = true -- Disables search result highlighting after the search is done

-- APPEARANCE ----------------------------------------------------------------
opt.number = true -- Make line numbers default
opt.relativenumber = false -- Turning off relativenumbering as I'm not using it
opt.termguicolors = true
opt.colorcolumn = "100" -- Highlights column 100
opt.signcolumn = "no" -- Disable the left gutter
opt.cmdheight = 1
opt.scrolloff = 15 -- Minimal number of screen lines to keep above and below the cursor.
opt.completeopt = "menuone,noinsert,noselect"
-- opt.conceallevel   = 2
opt.showmode = false -- Don't show the mode
opt.breakindent = true -- Wrapped lines are indented
opt.list = true -- Sets how neovim will display certain whitespace characters in the editor.
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.cursorline = true -- highlight the line you are on.
opt.foldlevel = 99 -- Set fold depth to 99

-- FUNCTIONALITY ----------------------------------------------------------------
opt.undofile = true -- Save undo history
opt.updatetime = 250 -- Decrease update time
opt.timeoutlen = 300 -- Decrease mapped sequece wait time
opt.inccommand = "split" -- Preview substitutions live, as you type
opt.splitright = true -- Always split the window to the right

-- NETRW ---------------------------------------------------------------------

vim.g.netrw_banner = 0 -- Remove the top banner
vim.g.netrw_hide = 1 -- hide the . and .. in netrw

-- Update the list stype
-- 0: Thin, one file per line
-- 1: Long, one file per line with file size and time stamp
-- 2: Wide, which is files in columns
-- 3: Tree style
vim.g.netrw_liststyle = 1

-- FILETYPE ------------------------------------------------------------------
vim.filetype.add({
    extension = {
        -- yml = "yamlansible",
        yml = "yaml",
    },
    filename = {
        ["JenkinsSync"] = "groovy",
    },
})

-- LOOK & FEEL ---------------------------------------------------------------
vim.cmd([[highlight CursorLine guibg=#101010 guifg=NONE]]) -- Change background color
