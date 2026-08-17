-- PARKED REFERENCE — not loaded by Hyprland. Translation of ../monitor.conf.
--
-- [OK] hl.monitor({ output=, mode=, position=, scale= }) is verbatim-confirmed.
-- [INFERRED] the `vrr` key on hl.monitor — the .conf set it via the trailing
--   `,vrr,1` per-monitor arg. If hl.monitor rejects `vrr`, set it globally
--   instead: hl.config({ misc = { vrr = 1 } })  (applies to all outputs).

hl.monitor({ output = "HDMI-A-1", mode = "5120x1440@240", position = "0x0", scale = 1, vrr = 1 })
hl.monitor({ output = "eDP-2", mode = "2560x1440@165", position = "2000x1440", scale = 1.25 })
