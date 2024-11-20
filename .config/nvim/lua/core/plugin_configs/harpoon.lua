local harpoon = require("harpoon")

---@diagnostic disable-next-line: missing-parameter
harpoon:setup()

local function map(lhs, rhs, opts)
    vim.keymap.set("n", lhs, rhs, opts or {})
end

map("<leader>a", function() harpoon:list():add() end)
map("<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
map("<leader>1", function() harpoon:list():select(1) end)
map("<leader>2", function() harpoon:list():select(2) end)
map("<leader>3", function() harpoon:list():select(3) end)
map("<leader>4", function() harpoon:list():select(4) end)

-- -- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end)
vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end)
