return {
  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = false,
    priority = 1000,
    config = function()
      local function set_theme()
        -- Determine system theme (macOS example: uses `osascript`)
        local system_theme = vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null || echo Light")
        local is_dark = system_theme:find("Dark") ~= nil

        -- Set the appropriate colorscheme and override background
        if is_dark then
          vim.opt.background = "dark"
          require('github-theme').setup({
            palettes = {
              github_dark_colorblind = {
                bg1 = '#000000', -- Override background
              },
            },
          })
          vim.cmd('colorscheme github_dark_colorblind')
        else
          vim.opt.background = "light"
          require('github-theme').setup({
            palettes = {
              github_light = {
                bg1 = '#ffffff', -- Override background
              },
            },
          })
          vim.cmd('colorscheme github_light')
        end
      end

      -- Set the initial theme based on the system's theme
      set_theme()

      -- Automatically update the theme when required
      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",
        callback = set_theme,
      })
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
