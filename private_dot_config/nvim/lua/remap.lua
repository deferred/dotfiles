-- Set leader key
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Try to prevent bad habits like using the arrow keys for movement. This is
-- not the only possible bad habit. For example, holding down the h/j/k/l keys
-- for movement, rather than using more efficient movement commands, is also a
-- bad habit. The former is enforceable through a .vimrc, while we don't know
-- how to prevent the latter.
-- Do this in normal mode...
vim.keymap.set("n", "<Left>", ":echoe 'Use h'<CR>")
vim.keymap.set("n", "<Right>", ":echoe 'Use l'<CR>")
vim.keymap.set("n", "<Up>", ":echoe 'Use k'<CR>")
vim.keymap.set("n", "<Down>", ":echoe 'Use j'<CR>")
-- ...and in insert mode
vim.keymap.set("i", "<Left>", "<ESC>:echoe 'Use h'<CR>")
vim.keymap.set("i", "<Right>", "<ESC>:echoe 'Use l'<CR>")
vim.keymap.set("i", "<Up>", "<ESC>:echoe 'Use k'<CR>")
vim.keymap.set("i", "<Down>", "<ESC>:echoe 'Use j'<CR>")

