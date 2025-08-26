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

				-- Change list mappings from <leader>x to <leader>L
				["<Leader>xq"] = false,
				["<Leader>Lq"] = { "<cmd>copen<cr>", desc = "Quickfix List" },
				["<Leader>xl"] = false,
				["<Leader>Ll"] = { "<cmd>lopen<cr>", desc = "Location List" },

				-- Change close window from <leadex>q to leader<x>
				["<Leader>q"] = false,
				["<Leader>x"] = { "<cmd>close<cr>", desc = "Close window" },

				-- Change close buffer from <leader>c to <leader>w
				["<Leader>c"] = false,
				["<Leader>w"] = { "<cmd>bd<cr>", desc = "Close buffer" },
				["<Leader>C"] = false,
				["<Leader>W"] = { "<cmd>bd!<cr>", desc = "Force close buffer" },
			},
		},
	},
}
