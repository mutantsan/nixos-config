local settings = require("settings")

hl.on("hyprland.start", function()
  -- Tell UWSM the compositor is up: exports the session variables to systemd
  -- and D-Bus and activates graphical-session.target, which starts Noctalia,
  -- the polkit agent and udiskie (user services, see ../hyprland.nix).
  hl.exec_cmd("uwsm finalize HYPRLAND_INSTANCE_SIGNATURE")

  hl.exec_cmd("hyprsunset")

  -- Drop-down terminal; the window rules park it on special:terminal.
  hl.exec_cmd(settings.apps.dropdown_terminal)
end)
