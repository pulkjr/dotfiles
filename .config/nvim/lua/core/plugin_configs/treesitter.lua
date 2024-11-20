require('nvim-treesitter.configs').setup({

    ensure_installed = {
        'lua',
        'luadoc',
        'bash',
        'diff',
        'html',
        'markdown',
        'markdown_inline',
        'vim',
        'vimdoc'
    },

    sync_install = false,

    auto_install = true,

    indent = {
        enable = true
    },

    highlight = {
        enable = true,

        additional_vim_regex_highlighting = false,
    },
})

local treesitter_parser_config = require('nvim-treesitter.parsers').get_parser_configs()
treesitter_parser_config.powershell = {
    install_info = {
        url = "~/.config/nvim/tree-sitter-parsers/tree-sitter-powershell",
        files = { "src/parser.c", "src/scanner.c"},
        branch = "main",
        generate_requires_npm = false,
        requires_generate_from_grammar = false,
    },
    filetype = "ps1",
}
