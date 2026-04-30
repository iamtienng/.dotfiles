return {
  {
    "projekt0n/github-nvim-theme",
    dependencies = {
      "nvim-lualine/lualine.nvim",
    },
    config = function()
      local palettes = {
        all = {
          bg1 = "#101216",
        },
      }

      local groups = {
        all = {
          Normal = { bg = "#101216", fg = "#ffffff" },
          NormalFloat = { bg = "#101216" },
          LineNr = { fg = "#444c56" },
        },
      }

      vim.cmd("highlight clear")
      if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
      end

      vim.opt.background = "dark"
      require("github-theme").setup({
        options = {
          transparent = false,
          hide_end_of_buffer = true,
          terminal_colors = true,
        },
        palettes = palettes,
        groups = groups,
      })
      vim.cmd("colorscheme github_dark_colorblind")

      require("lualine").setup({
        options = {
          theme = {
            normal = {
              a = { fg = "#ffffff", bg = "#101216", gui = "bold" },
              b = { fg = "#ffffff", bg = "#101216" },
              c = { fg = "#ffffff", bg = "#101216" },
            },
            inactive = {
              a = { fg = "#636e7b", bg = "#101216" },
              b = { fg = "#636e7b", bg = "#101216" },
              c = { fg = "#636e7b", bg = "#101216" },
            },
          },
        },
      })
    end,
  },
}
