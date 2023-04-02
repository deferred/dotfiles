-- Disable the default Vim startup message.
vim.opt.shortmess:append("I")

-- Show line numbers.
vim.opt.nu = true

-- This enables relative line numbering mode. With both number and
-- relativenumber enabled, the current line shows the true line number, while
-- all other lines (above and below) are numbered relative to the current line.
-- This is useful because you can tell, at a glance, what count is needed to
-- jump up or down to a particular line, by {count}k to go up or {count}j to go
-- down.
vim.opt.relativenumber = true

-- This setting makes search case-insensitive when all characters in the string
-- being searched are lowercase. However, the search becomes case-sensitive if
-- it contains any capital letters. This makes searching more convenient.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Time in milliseconds to wait for a key code sequence to complete.
vim.opt.ttimeoutlen = 1

-- 4 spaces indent.
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Do smart autoindenting when starting a new line.
vim.opt.smartindent = true

-- Do not wrap lines.
vim.opt.wrap = false

-- Enable 24-bit RGB color.
vim.opt.termguicolors = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 8

-- If this many milliseconds nothing is typed the swap file will be written to disk.
vim.opt.updatetime = 50

-- Show vertical column at this number of symbols.
-- vim.opt.colorcolumn = "120"

