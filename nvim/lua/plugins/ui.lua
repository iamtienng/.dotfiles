return { -- https://www.lazyvim.org/plugins/ui
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
  },
  {
    require("noice").setup({
      cmdline = {
        view = "cmdline",
      },
      color = { fg = "#ff9e64" },
    }),
  },
  {
    "folke/zen-mode.nvim",
    enabled = true,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
    },
  },
}
