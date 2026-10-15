-- Volume and media keys.
local sink = "@DEFAULT_AUDIO_SINK@"
local source = "@DEFAULT_AUDIO_SOURCE@"

o.bind("XF86AudioRaiseVolume", "Volume up", "wpctl set-volume -l 1 " .. sink .. " 5%+", { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down", "wpctl set-volume " .. sink .. " 5%-", { locked = true, repeating = true })
o.bind("XF86AudioMute", "Mute", "wpctl set-mute " .. sink .. " toggle", { locked = true })
o.bind("XF86AudioMicMute", "Mute microphone", "wpctl set-mute " .. source .. " toggle", { locked = true })

-- Precise volume controls.
o.bind("ALT + XF86AudioRaiseVolume", "Volume up precise", "wpctl set-volume -l 1 " .. sink .. " 1%+", { locked = true, repeating = true })
o.bind("ALT + XF86AudioLowerVolume", "Volume down precise", "wpctl set-volume " .. sink .. " 1%-", { locked = true, repeating = true })

-- Media controls.
o.bind("XF86AudioNext", "Next track", "playerctl next", { locked = true })
o.bind("ALT + XF86AudioPlay", "Next track", "playerctl next", { locked = true })
o.bind("XF86AudioPause", "Pause", "playerctl play-pause", { locked = true })
o.bind("XF86AudioPlay", "Play", "playerctl play-pause", { locked = true })
o.bind("XF86AudioPrev", "Previous track", "playerctl previous", { locked = true })
o.bind("ALT + SHIFT + XF86AudioPlay", "Previous track", "playerctl previous", { locked = true })
