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
o.window("(com\\.mitchellh\\.ghostty|special\\.terminal)", { tag = "+terminal" })

-- Floating windows.
o.window({ tag = "floating-window" }, { float = true, center = true, size = { 875, 600 } })

o.window("(mpv|org\\.gnome\\.Loupe)", { tag = "+floating-window" })

-- The portal only ever shows dialogs (file pickers, screen shares, permission
-- prompts), so every one of its windows floats.
o.window("xdg-desktop-portal-gtk", { tag = "+floating-window" })
o.window({
  class = "(org.gnome.Nautilus)",
  title = "^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to (open|save).*|[Cc]hoose.*)",
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

-- Open VS Code on workspace 1. Named, so o.code_here() can switch it off.
local code_rule = hl.window_rule({
  name = "code-workspace",
  match = { class = "^(code.*|com\\.microsoft\\.VSCode)$" },
  workspace = "1",
})

-- Called by hypr-code-here (../hyprland.nix) when a file is opened from another
-- app: the next VS Code window stays on the current workspace.
function o.code_here()
  code_rule:set_enabled(false)
  -- In case no window shows up.
  hl.timer(function()
    code_rule:set_enabled(true)
  end, { timeout = 10000, type = "oneshot" })
end

hl.on("window.open", function(w)
  if w.class:find("^code") or w.class == "com.microsoft.VSCode" then
    code_rule:set_enabled(true)
  end
end)

-- Drop-down terminal: park the "special.terminal" window on its own special
-- workspace. Toggle with F1 (see bindings/apps.lua).
o.window("special.terminal", { workspace = "special:terminal silent" })
