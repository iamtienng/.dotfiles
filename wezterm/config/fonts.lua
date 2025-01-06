local platform = require("utils.platform")
local wezterm = require("wezterm")

local font = "MesloLGS Nerd Font"

local font_size = platform().is_mac and 16 or 10
-- >- <- >= <= == ~= !=

return {
  -- font = wezterm.font(font),
  font = wezterm.font_with_fallback({
    font,
    "MesloLGS Nerd Font",
  }),
  font_size = font_size,

  --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
  freetype_load_target = "Normal", ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
  freetype_render_target = "Normal", ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
