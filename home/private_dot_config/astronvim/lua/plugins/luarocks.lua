return {
  {
    "vhyrro/luarocks.nvim",
    config = function(_, opts)
      local vendor = vim.fn.stdpath "data" .. "/lazy/luarocks.nvim/.rocks/share/lua/5.1/luarocks/vendor/?.lua"

      if not package.path:find(vendor, 1, true) then package.path = vendor .. ";" .. package.path end

      require("luarocks-nvim").setup(opts)
    end,
  },
}
