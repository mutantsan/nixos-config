local settings = require("settings")

hl.on("hyprland.start", function()
  -- Hand the session environment to systemd and D-Bus first, so portals and
  -- D-Bus activated services can reach the compositor.
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  -- Shell layer.
  hl.exec_cmd("noctalia")
  hl.exec_cmd("hyprsunset")
  hl.exec_cmd(settings.polkit_agent)
  hl.exec_cmd("udiskie --automount --no-notify --no-tray")

  -- Drop-down terminal; the window rules park it on special:terminal.
  hl.exec_cmd(settings.apps.dropdown_terminal)
end)
