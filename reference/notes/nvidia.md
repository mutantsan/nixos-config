Intel is now set as the primary renderer, but it only takes effect after you log out and back in (or reboot) — nothing has changed in the running session yet, and I haven't tested the new setup.

What I changed:

- ~/.config/uwsm/default: added AQ_DRM_DEVICES so Hyprland uses the Intel chip first and the Quadro second.
- ~/.config/hypr/gpu-intel and gpu-nvidia: symlinks to the cards' fixed PCI paths, so the order holds even if card0/card1 swap on a future boot.
- ~/.config/hypr/hyprland.lua: overrode Omarchy's __GLX_VENDOR_LIBRARY_NAME=nvidia with mesa, so X11 apps stop being forced onto the Quadro. The config reloaded with no errors.

After you log back in, run nvidia-smi: the process list should be empty or nearly so, with VRAM use far below the 1150 MiB it was at.

If the session doesn't come up, switch to a TTY (Ctrl+Alt+F3), log in, and run:

cp ~/.config/uwsm/default.bak.1791361464 ~/.config/uwsm/default
cp ~/.config/hypr/hyprland.lua.bak.1791361464 ~/.config/hypr/hyprland.lua

Then log in again and you are back on the old setup.

To run a specific app on the Quadro later, launch it with __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <app>.
