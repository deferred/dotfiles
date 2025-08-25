return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        -- Swap <leader>fo and <leader>fO keybindings
        ["<Leader>fo"] = { function() require("snacks").picker.recent({ filter = { cwd = true } }) end, desc = "Find old files (cwd)" },
        ["<Leader>fO"] = { function() require("snacks").picker.recent() end, desc = "Find old files" },

        -- Change save from <leader>w to <leader>s
        ["<Leader>s"] = { "<cmd>w<cr>", desc = "Save" },

        -- Change window close from <leader>q to <leader>w
        ["<Leader>w"] = { "<cmd>close<cr>", desc = "Close window" },
        ["<Leader>q"] = false, -- disable default quit mapping
      },
    },
  },
}
