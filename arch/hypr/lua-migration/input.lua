-- PARKED REFERENCE — not loaded by Hyprland. Translation of ../input.conf.
--
-- [OK] hl.config({ section = { key = value } }) and nested sub-tables
--   (input.touchpad) match the confirmed API shape.

hl.config({
  input = {
    kb_layout = "us",
    kb_options = "ctrl:nocaps",
    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,
    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.4,
    },
  },
})

-- [TODO — UNVERIFIED] windowrule Lua syntax was NOT in the wiki pages I could
-- read, so I will not fabricate it. Original .conf line was:
--   windowrule = match:class com.mitchellh.ghostty, scroll_touchpad 0.2
-- Look up the current `hl.windowrule` / rule API on your box before porting.
