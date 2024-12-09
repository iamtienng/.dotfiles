local gpu_adapters = require("utils.gpu_adapter")

return {
  animation_fps = 60,
  max_fps = 60,
  front_end = "WebGpu",
  webgpu_power_preference = "HighPerformance",
  webgpu_preferred_adapter = gpu_adapters:pick_best(),

  -- scrollbar
  enable_scroll_bar = false,

  -- tab bar
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  use_fancy_tab_bar = true,
  tab_max_width = 25,
  show_tab_index_in_tab_bar = false,
  show_new_tab_button_in_tab_bar = false,
  switch_to_last_active_tab_when_closing_tab = true,
  window_decorations = "INTEGRATED_BUTTONS|RESIZE",

  -- window
  window_padding = {
    left = 5,
    right = 10,
    top = 5,
    bottom = 0,
  },
  window_close_confirmation = "NeverPrompt",

  -- window_decorations = "None",
  inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.3,
  },
}
