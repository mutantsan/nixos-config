-- Hyprland entry point (Lua config, Hyprland >= 0.55).
--
-- Hyprland resolves symlinks before loading, so this file's own directory is
-- the Nix store copy of ./_hypr, which does not hold the generated
-- settings.lua. Search ~/.config/hypr as well.
local config_dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr"
local info = debug and debug.getinfo and debug.getinfo(1, "S")
local dir = info and info.source:match("^@(.*)/[^/]*$") or config_dir

package.path = dir .. "/?.lua;" .. config_dir .. "/?.lua;" .. package.path

-- require() caches modules, so drop ours or a config reload re-runs nothing.
for _, module in ipairs({
  "settings",
  "noctalia",
  "lib.helpers",
  "monitors",
  "looknfeel",
  "input",
  "windows",
  "bindings.tiling",
  "bindings.media",
  "bindings.clipboard",
  "bindings.apps",
  "autostart",
}) do
  package.loaded[module] = nil
end

require("lib.helpers")

require("monitors")
require("looknfeel")

-- Border colours from Noctalia's palette. Its hyprland theme template writes
-- ~/.config/hypr/noctalia.lua, which is missing until the first render.
if pcall(require, "noctalia") then
  require("noctalia").apply_theme()
end
require("input")
require("windows")

require("bindings.tiling")
require("bindings.media")
require("bindings.clipboard")
require("bindings.apps")

require("autostart")
