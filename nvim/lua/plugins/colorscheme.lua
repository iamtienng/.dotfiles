return {
  'projekt0n/github-nvim-theme',
  name = 'github-theme',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('github-theme').setup({
      -- Optionally customize your theme settings here
    })

    -- Function to detect system theme and switch colorscheme accordingly
    local function set_theme_based_on_system()
      local handle = io.popen("defaults read -g AppleInterfaceStyle")
      local result = handle:read("*a")
      handle:close()

      -- Check if the system is using dark mode
      if result:match("Dark") then
        vim.cmd('colorscheme github_dark_colorblind')
      else
        vim.cmd('colorscheme github_light_colorblind')
      end
    end

    -- Call the function to set the theme on startup
    set_theme_based_on_system()
  end,
}
