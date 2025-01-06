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
      local function set_theme()
        -- Determine system theme (macOS example: uses `osascript`)
        local system_theme =
          vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null || echo Light")
        local is_dark = system_theme:find("Dark") ~= nil
        if is_dark then
          vim.opt.background = "dark"
          vim.cmd("colorscheme github_dark_colorblind")
        else
          vim.opt.background = "light"
          vim.cmd("colorscheme github_light")
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
      return {
        options = {
          theme = "auto",
        },
      }
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- Let LazyVim use the same dynamic colorscheme
      colorscheme = function()
        return vim.opt.background:get() == "dark" and "github_dark_colorblind" or "github_light"
      end,
    },
  },
}
