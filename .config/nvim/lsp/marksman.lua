return {
    default_config = {
        cmd = { "marksman" },
        filetypes = { "markdown" },
        root_dir = vim.fs.dirname(vim.fs.find({ ".git", ".marksman.toml" }, { upward = true })[1]),
    },
}
