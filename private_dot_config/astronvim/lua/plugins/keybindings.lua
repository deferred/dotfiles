return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        -- Swap <leader>fo and <leader>fO keybindings
        ["<Leader>fo"] = { function() require("snacks").picker.recent({ filter = { cwd = true } }) end, desc = "Find old files (cwd)" },
        ["<Leader>fO"] = { function() require("snacks").picker.recent() end, desc = "Find old files" },
      },
    },
  },
}
