-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

hl.env("GDK_SCALE", "1")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })

-- Keep workspaces 1-5 around when empty, so the bar always shows all five.
for id = 1, 5 do
  hl.workspace_rule({ workspace = tostring(id), persistent = true })
end
