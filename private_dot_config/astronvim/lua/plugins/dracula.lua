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
          StatusLineNC = { bg = "#282a36" }, -- non-current window statusline

          -- tabline colors
          TabLine = { bg = "#44475a" }, -- change tabline background
          TabLineFill = { bg = "#44475a" }, -- fill area of tabline

          -- breadcrumb colors
          WinBar = { bg = "NONE" }, -- remove breadcrumbs background
          WinBarNC = { bg = "NONE" }, -- remove non-current breadcrumbs background
        },
      },
    },
  },
}
