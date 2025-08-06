return {
  {
    "projekt0n/github-nvim-theme",
    config = function()
      local palettes = {
        all = {
          bg1 = "#101216", -- Base background color for dark theme
        },
      }

      local groups = {
        all = {
          Normal = { bg = "#101216", fg = "#ffffff" },
          NormalFloat = { bg = "#101216" },
          LineNr = { fg = "#444c56" },
        },
      }

      local light_palettes = {
        all = {
          bg1 = "#f4f4f4", -- Base background color for light theme
        },
      }

      local light_groups = {
        all = {
          Normal = { bg = "#f4f4f4", fg = "#000000" },
          NormalFloat = { bg = "#f4f4f4" },
          LineNr = { fg = "#999999" },
        },
      }

      local function set_theme(mode)
        if mode == "dark" then
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
        else
          vim.opt.background = "light"
          require("github-theme").setup({
            options = {
              transparent = false,
              hide_end_of_buffer = true,
              terminal_colors = true,
            },
            palettes = light_palettes,
            groups = light_groups,
          })
          vim.cmd("colorscheme github_light_colorblind")
        end
      end

      local function set_lualine_theme(mode)
        local theme
        if mode == "dark" then
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
          }
        else
          theme = {
            normal = {
              a = { fg = "#000000", bg = "#f4f4f4", gui = "bold" },
              b = { fg = "#000000", bg = "#f4f4f4" },
              c = { fg = "#000000", bg = "#f4f4f4" },
            },
            inactive = {
              a = { fg = "#999999", bg = "#f4f4f4" },
              b = { fg = "#999999", bg = "#f4f4f4" },
              c = { fg = "#999999", bg = "#f4f4f4" },
            },
          }
        end

        require("lualine").setup({ options = { theme = theme } })
      end
      set_theme("dark")
      set_lualine_theme("dark")
    end,
  },
}
