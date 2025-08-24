-- set dracula colorscheme and customize UI colors
-- this overrides the default AstroUI colorscheme and highlighting

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    opts = {
      colorscheme = "dracula",
      highlights = {
        init = {
          -- statusline colors
          StatusLine = { bg = "#44475a" }, -- change statusline background
          StatusLineNC = { bg = "NONE" }, -- non-current window statusline

          -- tabline colors
          TabLine = { bg = "#44475a" }, -- change tabline background
          TabLineFill = { bg = "#44475a" }, -- fill area of tabline

          -- breadcrumb colors
          WinBar = { bg = "NONE" }, -- remove breadcrumbs background
          WinBarNC = { bg = "NONE" }, -- remove non-current breadcrumbs background

          -- dashboard colors
          SnacksDashboardHeader = { fg = "#bd93f9" }, -- purple for dashboard header/logo
          SnacksDashboardDesc = { fg = "#f8f8f2" }, -- foreground for menu descriptions like "New file"
          SnacksDashboardIcon = { fg = "#ff79c6" }, -- pink for dashboard icons
          SnacksDashboardKey = { fg = "#8be9fd" }, -- cyan for dashboard keys like "[f]"
          SnacksDashboardFooter = { fg = "#6272a4" }, -- comment color for footer/startup stats
          SnacksDashboardSpecial = { fg = "#50fa7b" }, -- green for special dashboard text
        },
      },
    },
  },
}
