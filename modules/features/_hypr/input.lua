-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    -- English + Ukrainian; Caps Lock switches between them, Right Alt is Compose.
    kb_layout = "us,ua",
    kb_options = "grp:caps_toggle,compose:ralt",
    follow_mouse = 1,

    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,
  },

  misc = {
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})
