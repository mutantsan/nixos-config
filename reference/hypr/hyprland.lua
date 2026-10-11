-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Always open VS Code on workspace 1.
o.window("^(code.*|com\\.microsoft\\.VSCode)$", { workspace = "1" })

-- Always open Zed on workspace 1.
o.window("^dev\\.zed\\.Zed$", { workspace = "1" })

-- Float the clipboard-manager TUI window (spawned by trigger.sh via ghostty --class).
o.window("floating.clipboard", { float = true, center = true, size = { 900, 600 } })

-- set opacity 1 for all windows
o.window(".*", { opacity = "1 1" })

-- Drop-down terminal: park the "special.terminal" Ghostty window on its own special
-- workspace. Toggle with F1 (see hypr/bindings.lua).
o.window("special.terminal", {
  workspace = "special:terminal silent",
  opacity = "1.0",
})

-- Use the scrolling layout on the dropdown-terminal workspace, matching the
-- numbered workspaces. Without this it stays on dwindle, where the
-- "single-window square aspect ratio" toggle
-- (omarchy hyprland window single square aspect) clamps the lone terminal to a
-- centered square with large side padding.
hl.workspace_rule({ workspace = "special:terminal", layout = "scrolling" })

-- Intel is the primary GPU (see AQ_DRM_DEVICES in ~/.config/uwsm/default), so
-- undo Omarchy's NVIDIA default that forces GLX apps onto the NVIDIA card.
hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")
