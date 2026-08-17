-- Personal autostart. Loaded after Omarchy defaults via require("hypr.autostart").
--
-- o.exec_on_start runs the command as-is at Hyprland start (like exec-once).
-- Use o.launch_on_start(...) instead to scope it under uwsm-app.

o.exec_on_start("fcitx5 --daemon")
