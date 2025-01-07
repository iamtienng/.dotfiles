return {
  {
    "vimpostor/vim-lumen",
    lazy = false,
  },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      local palettes = {
        all = {
          bg1 = "#101216", -- Base background color
        },
      }

      local groups = {
        all = {
          Normal = { bg = "#101216", fg = "fg1" },
          NormalFloat = { bg = "#101216" },
          LineNr = { fg = "#444c56" },
        },
      }

      local light_palettes = {
        all = {
          bg1 = "#f4f4f4", -- Base background color
        },
      }

      local light_groups = {
        all = {
          Normal = { bg = "#f4f4f4", fg = "fg1" },
          NormalFloat = { bg = "#f4f4f4" },
          LineNr = { fg = "#999999" },
        },
      }

      local function set_theme()
        -- Determine system theme (macOS example: uses `osascript`)
        local system_theme =
          vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null || echo Light")
        local is_dark = system_theme:find("Dark") ~= nil

        if is_dark then
          vim.opt.background = "dark"
          require('github-theme').setup({
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
          require('github-theme').setup({
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

      set_theme()

      -- Automatically update the theme when required
      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",
        callback = set_theme,
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function()
      local function get_lualine_theme()
        local background = vim.opt.background:get()
        if background == "dark" then
          return {
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
          return {
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
      end

      return {
        options = {
          theme = get_lualine_theme(),
        },
      }
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- Let LazyVim use the same dynamic colorscheme
      colorscheme = function()
        return vim.opt.background:get() == "dark" and "github_dark_colorblind" or "github_light_colorblind"
      end,
    },
  },
}

