-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List monitors and supported resolutions with: hyprctl monitors all
--
-- Ported from the old monitor.conf. The prior config set NO GDK_SCALE
-- (native 1x / 1.25x), so none is set here.

-- [VERIFY] `vrr = 1` on hl.monitor: the old .conf enabled VRR on this output
-- via the trailing `,vrr,1`. If hl.monitor rejects the key, drop it here and
-- set it globally instead: hl.config({ misc = { vrr = 1 } }).
hl.monitor({ output = "HDMI-A-1", mode = "5120x1440@240", position = "0x0", scale = 1, vrr = 1 })
hl.monitor({ output = "eDP-2", mode = "2560x1440@165", position = "2000x1440", scale = 1.25 })
