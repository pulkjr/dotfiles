local dap = require("dap")
local dapui = require("dapui")

--- open ui immediately when debugging starts
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

-- https://emojipedia.org/en/stickers/search?q=circle
vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define(
    "DapBreakpointCondition",
    { text = "🟨", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
)
vim.fn.sign_define("DapLogPoint", { text = "💬", texthl = "DapLogPoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "🔴", texthl = "DapStopped", linehl = "Visual", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "⭕", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })

-- more minimal ui
dapui.setup({
    expand_lines = true,
    controls = { enabled = false }, -- no extra play/step buttons
    floating = { border = "rounded" },
    -- Set dapui window
    render = {
        max_type_length = 60,
        max_value_lines = 200,
    },
    -- Only one layout: just the "scopes" (variables) list at the bottom
    layouts = {
        {
            elements = {
                { id = "scopes", size = 0.7 },
                { id = "console", size = 0.3 },
            },
            size = 20,
            position = "bottom",
        },
    },
})

-- KEYMAPS----------------------------------------
local map, opts = vim.keymap.set, { noremap = true, silent = true }

map("n", "<leader>du", function()
    dapui.toggle()
end, { noremap = true, silent = true, desc = "Toggle DAP UI" })

map({ "n", "v" }, "<leader>dw", function()
    require("dapui").eval(nil, { enter = true })
end, { noremap = true, silent = true, desc = "Add word under cursor to Watches" })

map({ "n", "v" }, "Q", function()
    require("dapui").eval()
end, {
    noremap = true,
    silent = true,
    desc = "Hover/eval a single value (opens a tiny window instead of expanding the full object) ",
})

-- TESTS----------------------------------------

local neotest = require("neotest")

map("n", "<leader>dt", function()
    neotest.run.run({ strategy = "dap" })
end, { desc = "Debug nearest test" })

map("n", "<F6>", function()
    neotest.run.run({ strategy = "dap" })
end, { desc = "Debug nearest test" })
