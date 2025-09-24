-- Add keybindings here, see https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
local on_attach = function(client, bufnr)
    -- Key mappings
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local opts = { noremap = true, silent = true }
    buf_set_keymap("n", "<CR>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap("n", "<leader>zi", ":ZkIndex<CR>", opts)
    buf_set_keymap("v", "<leader>zn", ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)
    buf_set_keymap("n", "<leader>zn", ":ZkNew {title = vim.fn.input('Title: ')}<CR>", opts)
    buf_set_keymap("n", "<leader>zl", ":ZkNew {dir = 'log'}<CR>", opts)
end

return {
    on_attach = on_attach,
    cmd = { "zk", "lsp" },
    filetypes = { "markdown" },
    -- root_dir = function()
    --     vim.lsp.util.util.root_pattern(".zk")
    --     -- return vim.loop.cwd()
    -- end,
    settings = {},
}
