local dap = require("dap")

local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"

local netcoredbg_adapter = {
    type = "executable",
    command = mason_path,
    args = { "--interpreter=vscode" },
}

dap.adapters.netcoredbg = netcoredbg_adapter -- needed for normal debugging
dap.adapters.coreclr = netcoredbg_adapter -- needed for unit test debugging

dap.configurations.cs = {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            -- return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/src/", "file")
            -- return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/net9.0/", "file")
            return require("dap-dll-autopicker").build_dll_path()
        end,

        -- justMyCode = false,
        -- stopAtEntry = false,
        -- -- program = function()
        -- --   -- todo: request input from ui
        -- --   return "/path/to/your.dll"
        -- -- end,
        -- env = {
        --   ASPNETCORE_ENVIRONMENT = function()
        --     -- todo: request input from ui
        --     return "Development"
        --   end,
        --   ASPNETCORE_URLS = function()
        --     -- todo: request input from ui
        --     return "http://localhost:5050"
        --   end,
        -- },
        -- cwd = function()
        --   -- todo: request input from ui
        --   return vim.fn.getcwd()
        -- end,
    },
}

local map = vim.keymap.set

local opts = { noremap = true, silent = true }

map("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", opts)
map("n", "<F9>", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
map("n", "<leader>b", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
map("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", opts)
map("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", opts)
map("n", "<F8>", "<Cmd>lua require'dap'.step_out()<CR>", opts)
-- map("n", "<F12>", "<Cmd>lua require'dap'.step_out()<CR>", opts)
map("n", "<leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", opts)
map("n", "<leader>dl", "<Cmd>lua require'dap'.run_last()<CR>", opts)
map(
    "n",
    "<leader>dt",
    "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>",
    { noremap = true, silent = true, desc = "debug nearest test" }
)
local function update_signcolumn()
    local breakpoints = require("dap").list_breakpoints()
    vim.wo.signcolumn = (#breakpoints > 0) and "yes" or "auto"
end

-- Call this after setting or clearing breakpoints
vim.keymap.set("n", "<F9>", function()
    require("dap").toggle_breakpoint()
    update_signcolumn()
end)
