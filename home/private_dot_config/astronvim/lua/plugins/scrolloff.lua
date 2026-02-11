-- Configure scrolloff option to keep lines visible when scrolling with C-d
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        scrolloff = 999,
      },
    },
  },
}
