-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    -- English + Ukrainian; Caps Lock switches between them, Right Alt is Compose.
    kb_layout = "us,ua",
    kb_variant = "",
    kb_model = "",
    kb_options = "grp:caps_toggle,compose:ralt",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,

    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,

    touchpad = {
      natural_scroll = false,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
    },
  },

  misc = {
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

-- Scroll nicely in the terminal.
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
