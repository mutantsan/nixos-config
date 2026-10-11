-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Replace SUPER+V (was: universal paste) with the clipboard manager.
hl.unbind("SUPER + V")
o.bind("SUPER + V", "Clipboard manager", "/home/cherry/.local/share/clipboard-manager/trigger.sh")

-- Drop-down terminal: toggle the special:terminal workspace with F1.
o.bind("F1", "Dropdown terminal", hl.dsp.workspace.toggle_special("terminal"))

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Disable all Hey webapp bindings.
hl.unbind("SUPER + SHIFT + E")       -- was: Email (Hey)
hl.unbind("SUPER + SHIFT + ALT + E") -- was: New email (Hey)
hl.unbind("SUPER + SHIFT + C")       -- was: Calendar (Hey)

-- Screenshot on SUPER+SHIFT+S, same as the PrintScreen key.
-- Unbind existing SUPER+SHIFT+S first (was: Google Maps webapp).
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
-- Define the modifier key (e.g., SUPER/Windows key)
