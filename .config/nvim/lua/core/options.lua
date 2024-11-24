local opt = vim.opt

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- TAB/INDENT ----------------------------------------------------------------
opt.tabstop     = 4
opt.shiftwidth  = 4
opt.softtabstop = 4
opt.expandtab   = true
opt.smartindent = true
opt.wrap        = false

-- SEARCH --------------------------------------------------------------------
opt.incsearch  = true
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = false

-- APPEARANCE ----------------------------------------------------------------
opt.number         = true -- Make line numbers default
opt.relativenumber = true
opt.termguicolors  = true
opt.colorcolumn    = "100"
opt.signcolumn     = "yes"
opt.cmdheight      = 1
opt.scrolloff      = 15 -- Minimal number of screen lines to keep above and below the cursor.
opt.completeopt    = "menuone,noinsert,noselect"
-- opt.conceallevel   = 2
opt.showmode       = false -- Don't show the mode
opt.breakindent    = true -- Wrapped lines are indented
opt.list           = true -- Sets how neovim will display certain whitespace characters in the editor.
opt.listchars      = { tab = '» ', trail = '·', nbsp = '␣' }
opt.cursorline     = true -- highlight the line you are on.

-- FUNCTIONALITY ----------------------------------------------------------------
opt.undofile   = true -- Save undo history
opt.updatetime = 250 -- Decrease update time
opt.timeoutlen = 300 -- Decrease mapped sequece wait time
opt.inccommand = 'split' -- Preview substitutions live, as you type

-- NETRW ---------------------------------------------------------------------

vim.g.netrw_banner = 0 -- Remove the top banner

-- Update the list stype
-- 0: Thin, one file per line
-- 1: Long, one file per line with file size and time stamp
-- 2: Wide, which is files in columns
-- 3: Tree style
vim.g.netrw_liststyle = 1

-- ANSIBLE/YAML --------------------------------------------------------------
vim.filetype.add({
  extension = {
    yml = 'yaml.ansible'
  }
})

--  --------------------------------------------------------------
