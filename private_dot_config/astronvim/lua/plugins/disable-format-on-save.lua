-- Disable automatic formatting on save for all files
-- This overrides the default AstroLSP format_on_save setting

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    opts = {
      formatting = {
        format_on_save = {
          enabled = false, -- disable format on save globally
        },
      },
    },
  },
}