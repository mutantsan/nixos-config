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
o.bind("SUPER + SPACE", "Launcher", "noctalia msg panel-toggle launcher")
o.bind("SUPER + ALT + SPACE", "Launcher", "noctalia msg panel-toggle launcher")
o.bind("SUPER + ESCAPE", "System menu", "hypr-power-menu")
o.bind("XF86PowerOff", "System menu", "hypr-power-menu", { locked = true })
o.bind("SUPER + K", "Keybindings", "hypr-keybindings")
o.bind("SUPER + CTRL + L", "Lock system", "loginctl lock-session")

-- Toggles.
o.bind("SUPER + SHIFT + SPACE", "Toggle top bar", "noctalia msg bar-toggle")
o.bind("SUPER + CTRL + I", "Toggle locking on idle", "noctalia msg caffeine-toggle")
o.bind("SUPER + CTRL + N", "Toggle nightlight", "hypr-nightlight")

-- Notifications. xkbcommon names the comma keysym "comma"; "COMMA" does not match.
o.bind("SUPER + comma", "Dismiss all notifications", "noctalia msg notification-clear-active")
o.bind("SUPER + CTRL + comma", "Toggle silencing notifications", "noctalia msg notification-dnd-toggle")
o.bind("SUPER + ALT + comma", "Invoke notification", "noctalia msg notification-invoke-latest")
o.bind("SUPER + SHIFT + ALT + comma", "Notification history", "noctalia msg panel-toggle control-center notifications")

-- Capture.
o.bind("PRINT", "Screenshot", "noctalia msg screenshot-region")
o.bind("SUPER + SHIFT + S", "Screenshot", "noctalia msg screenshot-region")
o.bind("CTRL + PRINT", "Screenshot of the whole screen", "noctalia msg screenshot-fullscreen")
o.bind("SUPER + PRINT", "Color picker", "pkill -x hyprpicker || hyprpicker -a")

-- Zoom.
o.bind("SUPER + CTRL + Z", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)

o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)
