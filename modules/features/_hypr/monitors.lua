-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local settings = require("settings")

-- XWayland apps render unscaled instead of blurry-upscaled; GTK ones stay at 1x.
hl.env("GDK_SCALE", "1")
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = settings.monitor_scale })

-- Keep workspaces 1-5 around when empty, so the bar always shows all five.
for id = 1, 5 do
  hl.workspace_rule({ workspace = tostring(id), persistent = true })
end
