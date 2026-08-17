-- Personal input overrides. Loaded after Omarchy defaults via
-- require("hypr.input"). Uncommented settings replace Omarchy's defaults.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    kb_layout = "us",
    kb_options = "ctrl:nocaps",

    -- Keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 250,

    -- Start with numlock on.
    numlock_by_default = true,

    touchpad = {
      -- Natural (inverse) scrolling.
      natural_scroll = true,
      -- Scroll speed.
      scroll_factor = 0.4,
    },
  },
})

-- Slower touchpad scroll in Ghostty (was: windowrule scroll_touchpad 0.2).
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
