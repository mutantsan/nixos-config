-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

o.window(".*", { suppress_event = "maximize" })

-- Fix some dragging issues with XWayland.
o.window(
  {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  { no_focus = true }
)

-- Terminal tag, so bindings can single terminals out (see bindings/clipboard.lua).
o.window("(Alacritty|kitty|com.mitchellh.ghostty|foot|org\\.codeberg\\.dnkl\\.foot|wezterm|special\\.terminal|floating\\.clipboard)", {
  tag = "+terminal",
})

-- Floating windows.
o.window({ tag = "floating-window" }, { float = true })
o.window({ tag = "floating-window" }, { center = true })
o.window({ tag = "floating-window" }, { size = { 875, 600 } })

o.window("(org.gnome.NautilusPreviewer|org.gnome.Evince|imv|mpv)", { tag = "+floating-window" })

-- The portal only ever shows dialogs (file pickers, screen shares, permission
-- prompts), so every one of its windows floats.
o.window("xdg-desktop-portal-gtk", { tag = "+floating-window" })
o.window({
  class = "(org.gnome.Nautilus)",
  title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
}, { tag = "+floating-window" })

-- Hide screen sharing notification windows.
o.window({ title = ".*is sharing.*" }, { workspace = "special silent" })

-- Picture-in-picture overlays.
o.window({ title = "(Picture.?in.?[Pp]icture)" }, {
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  move = { "(monitor_w-window_w-40)", "(monitor_h*0.04)" },
})

-- Prevent Telegram from stealing focus on new messages.
o.window("org.telegram.desktop", { focus_on_activate = false })

o.window("steam", { float = true, idle_inhibit = "fullscreen" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })

o.window("(Share|localsend)", { float = true, center = true })
o.window("localsend", { size = { 1100, 700 } })

-- Always open VS Code and Zed on workspace 1.
o.window("^(code.*|com\\.microsoft\\.VSCode)$", { workspace = "1" })
o.window("^dev\\.zed\\.Zed$", { workspace = "1" })

-- Float the clipboard manager (spawned by hypr-clipboard).
o.window("floating.clipboard", { float = true, center = true, size = { 900, 600 } })

-- Drop-down terminal: park the "special.terminal" window on its own special
-- workspace. Toggle with F1 (see bindings/apps.lua).
o.window("special.terminal", { workspace = "special:terminal silent" })
