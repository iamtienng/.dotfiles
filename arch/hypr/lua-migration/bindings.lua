-- PARKED REFERENCE — not loaded by Hyprland. Do NOT wire this in yet.
-- Translation of ../bindings.conf to the Hyprland 0.55+ Lua config API.
-- Activate only once Omarchy ships a Lua entrypoint (see NOTES at bottom).
--
-- Confidence:
--   [OK]       verbatim-confirmed against the Hyprland wiki source
--   [INFERRED] shape is right, exact dispatcher name from wiki summary — verify on the box

local mod = "SUPER"

-- Application launchers (were `bindd`, i.e. bind + description) --------------
-- [OK] hl.bind(keys, hl.dsp.exec_cmd(cmd), { description = "..." })
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd([[uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"]]), { description = "Terminal" })
hl.bind(mod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("omarchy-launch-browser"), { description = "Browser" })
hl.bind(mod .. " + SHIFT + F", hl.dsp.exec_cmd("uwsm-app -- nautilus --new-window"), { description = "File manager" })
hl.bind(mod .. " + ALT + SHIFT + F", hl.dsp.exec_cmd([[uwsm-app -- nautilus --new-window "$(omarchy-cmd-terminal-cwd)"]]), { description = "File manager (cwd)" })
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("omarchy-launch-browser"), { description = "Browser" })
hl.bind(mod .. " + SHIFT + ALT + B", hl.dsp.exec_cmd("omarchy-launch-browser --private"), { description = "Browser (private)" })
hl.bind(mod .. " + SHIFT + D", hl.dsp.exec_cmd("omarchy-launch-tui lazydocker"), { description = "Docker" })
hl.bind(mod .. " + SHIFT + O", hl.dsp.exec_cmd([[omarchy-launch-or-focus ^obsidian$ "uwsm-app -- obsidian"]]), { description = "Obsidian" })

-- Unbind Omarchy defaults ----------------------------------------------------
-- [OK] hl.unbind("SUPER + O") ; keycodes as "code:NN"
hl.unbind(mod .. " + L")
hl.unbind(mod .. " + code:61")
hl.unbind(mod .. " + ALT + code:61")
hl.unbind(mod .. " + TAB")

-- Service --------------------------------------------------------------------
hl.bind(mod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Focus, vim-style (was `movefocus, l/d/u/r`) --------------------------------
-- [INFERRED] movefocus -> hl.dsp.focus({ direction = ... })
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))

-- Layout ---------------------------------------------------------------------
-- [INFERRED] layoutmsg -> hl.dsp.layout(message)
hl.bind(mod .. " + slash", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + slash", hl.dsp.layout("togglesplit"))
-- [OK] togglefloating -> hl.dsp.window.float({ action = "toggle" })
hl.bind(mod .. " + CTRL + F", hl.dsp.window.float({ action = "toggle" }))
-- [INFERRED] fullscreen -> hl.dsp.window.fullscreen({ action = "toggle" })
hl.bind(mod .. " + CTRL + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Workspaces -----------------------------------------------------------------
-- [INFERRED] workspace previous -> hl.dsp.focus({ workspace = "previous" })
hl.bind(mod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))
-- [INFERRED] movecurrentworkspacetomonitor +1 -> hl.dsp.workspace.move({ monitor = "+1" })
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.workspace.move({ monitor = "+1" }))
