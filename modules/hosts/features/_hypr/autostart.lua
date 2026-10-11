local settings = require("settings")

hl.on("hyprland.start", function()
  -- Hand the session environment to systemd and D-Bus first, so portals and
  -- D-Bus activated services (mako) can reach the compositor.
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  -- Shell layer.
  hl.exec_cmd("waybar")
  hl.exec_cmd("mako")
  hl.exec_cmd("vicinae server")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("hyprsunset")
  hl.exec_cmd("hypr-wallpaper")
  hl.exec_cmd(settings.polkit_agent)
  hl.exec_cmd("udiskie --automount --no-notify --no-tray")

  -- Clipboard history, plus the clipboard-manager daemon when it is installed.
  hl.exec_cmd("wl-paste --watch cliphist store")
  hl.exec_cmd("hypr-clipboard --daemon")

  -- Drop-down terminal; the window rules park it on special:terminal.
  hl.exec_cmd(settings.apps.dropdown_terminal)
end)
