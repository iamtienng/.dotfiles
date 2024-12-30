local wezterm = require("wezterm")

return {
  keys = {
    -- Pane splitting
    {
      key = "d",
      mods = "CMD",
      action = wezterm.action.SplitHorizontal,
    },

    {
      key = "d",
      mods = "SHIFT|CMD",
      action = wezterm.action.SplitVertical,
    },

    -- Pane closing
    {
      key = "w",
      mods = "CMD",
      action = wezterm.action({ CloseCurrentPane = { confirm = true } }),
    },

    -- Pane full screen
    {
      key = "Enter",
      mods = "CMD|SHIFT",
      action = wezterm.action.TogglePaneZoomState,
    },

    -- Command prompt word navigation
    { key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
    { key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },

    -- Pane navigation
    { key = "UpArrow", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "DownArrow", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Down") },
    { key = "LeftArrow", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Right") },

    -- Command+option+arrows to move between tabs
    { key = "LeftArrow", mods = "CMD|OPT", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "CMD|OPT", action = wezterm.action.ActivateTabRelative(1) },

    -- Clear terminal
    {
      key = "k",
      mods = "CMD",
      action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
    },

    -- Natural Text Editing
    {
      mods = "OPT",
      key = "LeftArrow",
      action = wezterm.action.SendKey({ mods = "ALT", key = "b" }),
    },
    {
      mods = "OPT",
      key = "RightArrow",
      action = wezterm.action.SendKey({ mods = "ALT", key = "f" }),
    },
    {
      mods = "CMD",
      key = "LeftArrow",
      action = wezterm.action.SendKey({ mods = "CTRL", key = "a" }),
    },
    {
      mods = "CMD",
      key = "RightArrow",
      action = wezterm.action.SendKey({ mods = "CTRL", key = "e" }),
    },
    {
      mods = "CMD",
      key = "Backspace",
      action = wezterm.action.SendKey({ mods = "CTRL", key = "u" }),
    },
    {
      key = "f",
      mods = "CTRL",
      action = wezterm.action_callback(function(win, pane)
        local cmd = "~/.config/scripts/tmux-sessionizer" -- Path to your script
        win:perform_action(
          wezterm.action.SpawnCommandInNewTab({
            args = { "zsh", "-c", cmd },
          }),
          pane
        )
      end),
    },
  },
}
