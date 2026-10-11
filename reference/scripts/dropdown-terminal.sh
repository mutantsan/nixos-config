#!/bin/bash
# Drop-down terminal toggle for the special:terminal workspace.
# If the foot window was closed (e.g. Super+W), respawn it before toggling so
# F1 always brings a terminal back. See ~/.config/hypr/bindings.lua.

app_id="special.terminal"

if ! hyprctl clients -j | jq -e --arg c "$app_id" 'any(.[]; .class == $c)' >/dev/null; then
    setsid -f foot --app-id="$app_id" >/dev/null 2>&1

    # Wait briefly for the window rules to park it on special:terminal.
    for _ in $(seq 1 20); do
        if hyprctl clients -j | jq -e --arg c "$app_id" 'any(.[]; .class == $c)' >/dev/null; then
            break
        fi
        sleep 0.05
    done
fi

hyprctl dispatch 'hl.dsp.workspace.toggle_special("terminal")'
