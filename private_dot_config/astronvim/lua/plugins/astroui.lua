-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
	"AstroNvim/astroui",
	---@type AstroUIOpts
	opts = {
		-- change colorscheme
		colorscheme = "dracula",
		-- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
		highlights = {
			init = { -- this table overrides highlights in all themes
				-- Normal = { bg = "#000000" },
				StatusLine = { bg = "#44475a" }, -- change statusline background
				StatusLineNC = { bg = "#282a36" }, -- non-current window statusline
				WinBar = { bg = "NONE" }, -- remove breadcrumbs background
				WinBarNC = { bg = "NONE" }, -- remove non-current breadcrumbs background
			},
			astrodark = { -- a table of overrides/changes when applying the astrotheme theme
				-- Normal = { bg = "#000000" },
			},
		},
		-- Icons can be configured throughout the interface
		icons = {
			-- configure the loading of the lsp in the status line
			LSPLoading1 = "⠋",
			LSPLoading2 = "⠙",
			LSPLoading3 = "⠹",
			LSPLoading4 = "⠸",
			LSPLoading5 = "⠼",
			LSPLoading6 = "⠴",
			LSPLoading7 = "⠦",
			LSPLoading8 = "⠧",
			LSPLoading9 = "⠇",
			LSPLoading10 = "⠏",
		},
	},
}
