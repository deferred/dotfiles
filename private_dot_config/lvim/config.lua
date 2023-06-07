require("user.lualine")
require("user.options")
require("user.plugins")
require("user.telescope")
require("user.which_key")

-- automatically install python syntax highlighting
lvim.builtin.treesitter.ensure_installed = {
    "python",
}

-- setup formatting
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup { { name = "black" }, }
lvim.format_on_save.enabled = true
lvim.format_on_save.pattern = { "*.py" }

-- setup linting
local linters = require "lvim.lsp.null-ls.linters"
linters.setup { { command = "mypy", filetypes = { "python" } } }

require('swenv').setup({
    -- Should return a list of tables with a `name` and a `path` entry each.
    -- Gets the argument `venvs_path` set below.
    -- By default just lists the entries in `venvs_path`.
    get_venvs = function()
        local a = {}
        local f = io.popen("poetry env list --full-path")
        for line in f:lines() do
            table.insert(a, line)
        end
        return a
    end,
    -- Path passed to `get_venvs`.
    venvs_path = vim.fn.expand('~/Library/Caches/pypoetry/virtualenvs'),
    -- Something to do after setting an environment
    post_set_venv = function()
        vim.cmd("LspRestart")
    end,
})

-- binding for switching
lvim.builtin.which_key.mappings["C"] = {
    name = "Python",
    c = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Choose Env" },
}

lvim.colorscheme = "dracula"
