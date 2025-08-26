return {
	"AstroNvim/astrocore",
	opts = {
		mappings = {
			n = {
				-- Swap <leader>fo and <leader>fO keybindings
				["<Leader>fo"] = {
					function()
						require("snacks").picker.recent({ filter = { cwd = true } })
					end,
					desc = "Find old files (cwd)",
				},
				["<Leader>fO"] = {
					function()
						require("snacks").picker.recent()
					end,
					desc = "Find old files",
				},

				-- Change save from <leader>w to <leader>s
				["<Leader>s"] = { "<cmd>w<cr>", desc = "Save" },

				-- Buffer and window management
				["<Leader>w"] = { "<cmd>bd<cr>", desc = "Close buffer" },
				["<Leader>W"] = { "<cmd>bd!<cr>", desc = "Force close buffer" },
				["<Leader>x"] = { "<cmd>close<cr>", desc = "Close window" },
				["<Leader>q"] = false, -- disable default quit mapping
			},
		},
	},
}
