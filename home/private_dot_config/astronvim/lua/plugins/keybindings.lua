return {
	"AstroNvim/astrocore",
	opts = {
		mappings = {
			n = {
			-- Recently changed files from git log
			["<Leader>gh"] = {
				function()
					local snacks = require("snacks")
					local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
					if vim.v.shell_error ~= 0 then
						snacks.notify.error("Not in a git repository")
						return
					end
					local files = vim.fn.systemlist(
						"git log --name-only --pretty=format: | grep -v '^$' | awk '!seen[$0]++'"
					)
					if #files == 0 then
						snacks.notify.warn("No recently changed files found")
						return
					end
					snacks.picker({
						title = "Git Recently Changed Files",
						items = vim.tbl_map(function(f)
							return { text = f, file = git_root .. "/" .. f }
						end, files),
						format = "file",
						preview = "file",
					})
				end,
				desc = "Git recently changed files",
			},
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
			},
		},
	},
}
