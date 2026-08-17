-- PARKED REFERENCE — not loaded by Hyprland. Translation of ../autostart.conf.
--
-- [INFERRED — VERIFY] I could not confirm the Lua `exec-once` equivalent from
-- the wiki pages I read. `hl.exec_once(cmd)` is the most likely name; if it
-- errors, check the wiki for the load-time exec API before relying on it.
-- Original: exec-once = fcitx5 --daemon

hl.exec_once("fcitx5 --daemon")
