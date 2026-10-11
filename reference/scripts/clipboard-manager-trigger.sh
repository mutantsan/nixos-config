#!/bin/bash
BINARY="/home/cherry/.cargo/bin/clipboard-manager-ms"

# Single-instance guard: if a clipboard UI is already open, just refocus it
# (Hyprland) and bail out instead of spawning another terminal window.
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/clipboard-manager"
LOCK_FILE="$DATA_DIR/ui.lock"
if [ -f "$LOCK_FILE" ] && kill -0 "$(cat "$LOCK_FILE" 2>/dev/null)" 2>/dev/null; then
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && command -v hyprctl &> /dev/null; then
        # Hyprland's Lua config (e.g. Omarchy) rejects the classic
        # "dispatch focuswindow class:..." syntax, so try the Lua dispatcher
        # first and fall back to the classic one for stock Hyprland.
        hyprctl dispatch 'hl.dsp.focus({ window = "class:floating-clipboard" })' > /dev/null 2>&1 \
            || hyprctl dispatch focuswindow "class:floating-clipboard" > /dev/null 2>&1
    fi
    exit 0
fi

if command -v kitty &> /dev/null; then
    kitty --class floating-clipboard \
          --title "Clipboard Manager" \
          -o initial_window_width=900 \
          -o initial_window_height=600 \
          -o remember_window_size=no \
          "$BINARY" --ui &
elif command -v alacritty &> /dev/null; then
    alacritty --class floating-clipboard \
              --title "Clipboard Manager" \
              -o window.dimensions.columns=100 \
              -o window.dimensions.lines=30 \
              -e "$BINARY" --ui &
elif command -v foot &> /dev/null; then
    foot --app-id=floating-clipboard \
         --title="Clipboard Manager" \
         --window-size-chars=100x30 \
         "$BINARY" --ui &
else
    notify-send "Clipboard Manager" "No suitable terminal found"
fi
