local wezterm = require 'wezterm'

-- Define the light and dark themes
local light_theme = {
  foreground = "#24292f",
  background = "#ffffff",
  cursor_bg = "#24292f",
  cursor_border = "#24292f",
  cursor_fg = "#ffffff",
  selection_bg = "#bbdfff",
  selection_fg = "#24292f",
  ansi = {"#24292f", "#b35900", "#0550ae", "#4d2d00", "#0969da", "#8250df", "#1b7c83", "#6e7781"},
  brights = {"#57606a", "#8a4600", "#0969da", "#633c01", "#218bff", "#a475f9", "#3192aa", "#8c959f"},
}

local dark_theme = {
  foreground = "#c9d1d9",
  background = "#000000",
  cursor_bg = "#c9d1d9",
  cursor_border = "#c9d1d9",
  cursor_fg = "#0d1117",
  selection_bg = "#1e4273",
  selection_fg = "#c9d1d9",
  ansi = {
    '#484f58',
    '#ec8e2c',
    '#58a6ff',
    '#d29922',
    '#58a6ff',
    '#bc8cff',
    '#39c5cf',
    '#b1bac4',},
  brights = {
    '#6e7681',
    '#fdac54',
    '#79c0ff',
    '#e3b341',
    '#79c0ff',
    '#d2a8ff',
    '#56d4dd',
    '#ffffff',},
}

-- Function to get theme based on appearance
local function get_theme()
  if wezterm.gui.get_appearance() == "Dark" then
    return dark_theme
  else
    return light_theme
  end
end

-- Dynamically apply the theme
wezterm.on("update-right-status", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  overrides.colors = get_theme()
  window:set_config_overrides(overrides)
end)

-- Default settings (use dark theme as the initial theme)
return {
  colors = dark_theme, -- Default theme
}
