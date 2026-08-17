-- Personal keybinding overrides. Loaded after Omarchy defaults via
-- require("hypr.bindings").
--
-- Dialect:
--   o.bind(keys, description, "shell cmd")  -- launches (auto exec_cmd)
--   hl.bind(keys, hl.dsp.*)                 -- dispatchers
--   hl.unbind(keys)                         -- remove a default
-- See current bindings: omarchy menu keybindings --print

local mod = "SUPER"

-- IMPORTANT: hl.bind ADDS a binding, it does not replace. Omarchy already
-- binds several of these keys (terminal, browser, ...), so we must clear each
-- key we redefine first — otherwise the key fires twice (double windows).
for _, keys in ipairs({
  mod .. " + RETURN",
  mod .. " + SHIFT + RETURN",
  mod .. " + SHIFT + F",
  mod .. " + ALT + SHIFT + F",
  mod .. " + SHIFT + B",
  mod .. " + SHIFT + ALT + B",
  mod .. " + SHIFT + D",
  mod .. " + SHIFT + O",
  mod .. " + R",
  mod .. " + H",
  mod .. " + J",
  mod .. " + K",
  mod .. " + L",
  mod .. " + code:61",
  mod .. " + ALT + code:61",
  mod .. " + slash",
  mod .. " + SHIFT + slash",
  mod .. " + CTRL + F",
  mod .. " + CTRL + SHIFT + F",
  mod .. " + TAB",
  mod .. " + SHIFT + TAB",
}) do
  hl.unbind(keys)
end

-- Application launchers ------------------------------------------------------
o.bind(mod .. " + RETURN", "Terminal", [[uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"]])
o.bind(mod .. " + SHIFT + RETURN", "Browser", "omarchy-launch-browser")
o.bind(mod .. " + SHIFT + F", "File manager", "uwsm-app -- nautilus --new-window")
o.bind(mod .. " + ALT + SHIFT + F", "File manager (cwd)", [[uwsm-app -- nautilus --new-window "$(omarchy-cmd-terminal-cwd)"]])
o.bind(mod .. " + SHIFT + B", "Browser", "omarchy-launch-browser")
o.bind(mod .. " + SHIFT + ALT + B", "Browser (private)", "omarchy-launch-browser --private")
o.bind(mod .. " + SHIFT + D", "Docker", "omarchy-launch-tui lazydocker")
o.bind(mod .. " + SHIFT + O", "Obsidian", [[omarchy-launch-or-focus ^obsidian$ "uwsm-app -- obsidian"]])

-- Service --------------------------------------------------------------------
o.bind(mod .. " + R", "Reload Hyprland", "hyprctl reload")

-- Focus, vim-style (movefocus l/d/u/r) ---------------------------------------
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))

-- Layout ---------------------------------------------------------------------
-- [VERIFY] layoutmsg -> hl.dsp.layout(msg): confirm the dispatcher name on 0.56.
hl.bind(mod .. " + slash", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + slash", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + CTRL + F", hl.dsp.window.float({ action = "toggle" }))
-- [VERIFY] fullscreen dispatcher shape.
hl.bind(mod .. " + CTRL + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Workspaces -----------------------------------------------------------------
-- [VERIFY] "previous" workspace keyword in Lua form.
hl.bind(mod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))
-- [VERIFY] movecurrentworkspacetomonitor -> hl.dsp.workspace.move({ monitor }).
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.workspace.move({ monitor = "+1" }))
