local wezterm = require 'wezterm'

local light_theme = {
  colors = {
    foreground = "#24292f",
    background = "#ffffff",
    cursor_bg = "#24292f",
    cursor_border = "#24292f",
    cursor_fg = "#ffffff",
    selection_bg = "#bbdfff",
    selection_fg = "#24292f",
    ansi = {"#24292f", "#b35900", "#0550ae", "#4d2d00", "#0969da", "#8250df", "#1b7c83", "#6e7781"},
    brights = {"#57606a", "#8a4600", "#0969da", "#633c01", "#218bff", "#a475f9", "#3192aa", "#8c959f"},
    tab_bar = {
      background = '#ffffff',
      active_tab = {
        bg_color = '#ffffff',
        fg_color = '#000000',
      },
      inactive_tab = {
        bg_color = '#f0f0f0',
        fg_color = '#333333',
      },
      inactive_tab_hover = {
        bg_color = '#dddddd',
        fg_color = '#111111',
      },
    },
  },
  window_frame = {
    active_titlebar_bg = "#ffffff",
    font_size = 15.0,
  },
}

local dark_theme = {
  colors = {
    foreground = "#c9d1d9",
    background = "#000000",
    cursor_bg = "#c9d1d9",
    cursor_border = "#c9d1d9",
    cursor_fg = "#0d1117",
    selection_bg = "#1e4273",
    selection_fg = "#c9d1d9",
    ansi = {'#484f58', '#ec8e2c', '#58a6ff', '#d29922', '#58a6ff', '#bc8cff', '#39c5cf', '#b1bac4',},
    brights = {'#6e7681', '#fdac54', '#79c0ff', '#e3b341', '#79c0ff', '#d2a8ff', '#56d4dd', '#ffffff',},
    tab_bar = {
      background = '#000000',
      active_tab = {
        bg_color = '#000000',
        fg_color = '#ffffff',
      },
      inactive_tab = {
        bg_color = '#333333',
        fg_color = '#888888',
      },
      inactive_tab_hover = {
        bg_color = '#444444',
        fg_color = '#bbbbbb',
      },
      inactive_tab_edge = '#888888',
    },
  },
  window_frame = {
    -- font = wezterm.font { family = '"MesloLGS NF', weight = 'Bold' },
    active_titlebar_bg = "#000000",
    font_size = 15.0,
  },
}

local function get_theme()
  if wezterm.gui.get_appearance() == "Dark" then
    return dark_theme.colors, dark_theme.window_frame
  else
    return light_theme.colors, light_theme.window_frame
  end
end

wezterm.on("update-right-status", function(window, _pane)
  local colors, window_frame = get_theme()
  local overrides = window:get_config_overrides() or {}
  overrides.colors = colors
  overrides.window_frame = window_frame 
  window:set_config_overrides(overrides)
end)

return {
  colors = dark_theme.colors,
  window_frame = dark_theme.window_frame
}
