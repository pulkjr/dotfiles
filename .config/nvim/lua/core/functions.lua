vim.api.nvim_create_user_command("W", function()
    vim.cmd("w")
end, { desc = "Save this file" })

vim.api.nvim_create_user_command("Q", function()
    vim.cmd("q")
end, { desc = "Quit" })

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
