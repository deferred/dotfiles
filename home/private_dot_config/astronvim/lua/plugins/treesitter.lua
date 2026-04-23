-- Customize Treesitter
-- In AstroNvim v6, nvim-treesitter is configured via AstroCore's `treesitter` table.
-- See: https://docs.astronvim.com/recipes/treesitter/

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      ensure_installed = {
        "ssh_config",
        -- add more parsers here; lua/vim/vimdoc and common parsers come from AstroNvim defaults
      },
    },
  },
}
