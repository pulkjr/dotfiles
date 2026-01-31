-- Add keybindings here, see https://github.com/neovim/nvim-lspconfig#keybindings-and-completion

local zk_root = vim.fn.expand("~/git/Personal/dailyZK")

local on_attach = function(client, bufnr)
    local map = function(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true })
    end
    -- LSP basics
    map("n", "K", vim.lsp.buf.hover)
    map("n", "<CR>", vim.lsp.buf.definition)

    -- Follow [[links]] with Enter
    map("n", "gd", vim.lsp.buf.definition)
    map("n", "gr", vim.lsp.buf.references)

    -- ZK commands
    map("n", "<leader>zi", "<cmd>ZkIndex<CR>")
    map("n", "<leader>zs", "<cmd>ZkNotes<CR>")
    map("n", "<leader>zt", "<cmd>ZkTags<CR>")

    -- Create a new note with title prompt
    map("n", "<leader>zn", function()
        require("zk.commands").get("ZkNew")({ title = vim.fn.input("Title: ") })
    end)

    -- Create a note in the "log" directory
    map("n", "<leader>zl", function()
        require("zk.commands").get("ZkNew")({ dir = "log" })
    end)

    -- Insert a link to another note
    map("n", "<leader>zl", "<cmd>ZkLink<CR>")
end

return {
    on_attach = on_attach,
    cmd = { "zk", "lsp" },
    filetypes = { "markdown" },
    root_dir = function(fname)
        local fullpath = vim.fn.fnamemodify(fname, ":p")
        if fullpath:find(zk_root, 1, true) then
            return zk_root
        end
        -- Returning nil tells Neovim NOT to start zk-lsp
        return nil
    end,
    settings = {},
}
