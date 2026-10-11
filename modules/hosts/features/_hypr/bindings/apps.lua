local apps = require("settings").apps

-- Applications.
o.bind("SUPER + RETURN", "Terminal", apps.terminal)
o.bind("SUPER + SHIFT + RETURN", "Browser", apps.browser)
o.bind("SUPER + SHIFT + B", "Browser", apps.browser)
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", apps.browser_private)
o.bind("SUPER + SHIFT + F", "File manager", apps.files)
o.bind("SUPER + SHIFT + N", "Editor", apps.editor)
o.bind("SUPER + ALT + RETURN", "Tmux", apps.terminal .. " -e tmux new-session -A -s Work")
o.bind("SUPER + CTRL + T", "Activity", apps.terminal .. " -e btop")

-- Drop-down terminal on the special:terminal workspace.
o.bind("F1", "Dropdown terminal", "hypr-dropdown-terminal")

-- Menus.
o.bind("SUPER + SPACE", "Launcher", "pkill -x fuzzel || fuzzel")
o.bind("SUPER + ALT + SPACE", "Launcher", "pkill -x fuzzel || fuzzel")
o.bind("SUPER + ESCAPE", "System menu", "hypr-power-menu")
o.bind("XF86PowerOff", "System menu", "hypr-power-menu", { locked = true })
o.bind("SUPER + K", "Keybindings", "hypr-keybindings")
o.bind("SUPER + CTRL + L", "Lock system", "loginctl lock-session")

-- Toggles.
o.bind("SUPER + SHIFT + SPACE", "Toggle top bar", "pkill -SIGUSR1 -x waybar")
o.bind("SUPER + CTRL + I", "Toggle locking on idle", "hypr-idle-toggle")
o.bind("SUPER + CTRL + N", "Toggle nightlight", "hypr-nightlight")

-- Notifications. xkbcommon names the comma keysym "comma"; "COMMA" does not match.
o.bind("SUPER + comma", "Dismiss last notification", "makoctl dismiss")
o.bind("SUPER + SHIFT + comma", "Dismiss all notifications", "makoctl dismiss --all")
o.bind("SUPER + CTRL + comma", "Toggle silencing notifications", "makoctl mode -t do-not-disturb")
o.bind("SUPER + ALT + comma", "Invoke last notification", "makoctl invoke")
o.bind("SUPER + SHIFT + ALT + comma", "Restore last notification", "makoctl restore")

-- Capture.
o.bind("PRINT", "Screenshot", "hypr-screenshot")
o.bind("SUPER + SHIFT + S", "Screenshot", "hypr-screenshot")
o.bind("CTRL + PRINT", "Screenshot of the whole screen", "hypr-screenshot screen")
o.bind("SUPER + PRINT", "Color picker", "pkill -x hyprpicker || hyprpicker -a")

-- Zoom.
o.bind("SUPER + CTRL + Z", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)

o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)
