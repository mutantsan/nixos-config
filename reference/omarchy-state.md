# Omarchy state snapshot — source machine

Captured 2026-09-10 from the current Omarchy install, to be reproduced on the
NixOS machine. This is reference material, not config that gets applied.

## System

| | |
|---|---|
| Distro | Omarchy 4.0.3-1, **stable** channel |
| Base | Arch (`ID_LIKE=arch`) |
| WM | Hyprland, configured via the **Lua API** (`hl.*` / `o.*` DSL, needs Hyprland ≥ 0.55) |
| Bar / shell | **QuickShell**-based (`quickshell`, `herdr`, `gtk4-layer-shell`) — *not* waybar |
| Theme engine | `aether` |
| Active theme | **Nord** (`omarchy theme current`) |
| Login | SDDM |
| Display scale | monitor `scale = 1.25`, `GDK_SCALE = 1` |
| Keyboard | `kb_layout = us,ua`; `kb_options = compose:caps,shift:both_capslock_cancel,grp:caps_toggle` |
| Audio | PipeWire + WirePlumber + `pipewire-pulse` |
| Input remap | `keyd` — `/etc/keyd/default.conf` maps Fn row to media keys (see `../reference` via dotfiles `etc/keyd/`) |
| AUR / foreign pkgs | only `docker-sbx`, `slack-desktop` |
| Explicit pkgs | 176 (see `packages-explicit.txt`) |

## Personal Hyprland overrides (`~/.config/hypr/*.lua`)

Copied verbatim into `reference/hypr/`. These are the layer to re-create on NixOS.
nixarchy leaves `~/.config/hypr/` alone if it already exists, and both the
"Omarchy" and personal sessions read these five files from `$HOME`.

- **monitors.lua** — `scale = 1.25`, `GDK_SCALE = 1`.
- **input.lua** — dual layout `us,ua`, caps as compose + layout toggle.
- **bindings.lua** —
  - `SUPER+V` → clipboard-manager (`~/.local/share/clipboard-manager/trigger.sh`)
  - `F1` → toggle special `terminal` workspace (drop-down Ghostty)
  - `SUPER+SHIFT+S` → `omarchy-capture-screenshot`
- **hyprland.lua** — VS Code always on workspace 1; float rules for the
  clipboard-manager TUI and the drop-down terminal; `special:terminal`
  workspace uses the scrolling layout; opacity forced to 1 for all windows.
- **looknfeel.lua** — no animation on the special workspace; `focus_on_activate = false`.
- **autostart.lua** — spawns `clipboard-manager-ms` daemon and the drop-down
  Ghostty window (`--class=special.terminal`).

## Omarchy customizations beyond hypr

- **`~/.config/omarchy/extensions/omarchy-menu.jsonc`** — personal menu overrides
  (copied to `reference/omarchy/`). Managed with the `omarchy-sc` helper
  (github.com/mutantsan/omarchy-sc) which hides/adds menu suggestions.
- **QuickShell bar plugins** (`~/.config/omarchy/plugins/`):
  - `io.github.tyrichards.tray`
  - `mutantsan.solr-status`  *(your own — `~/pet/solr-status`)*
  - `njpatel.omapager`
  - `stappmus.activity-monitor`
  - `zeru.portwatch`
- **`~/.config/herdr/config.toml`**, **`~/.config/omarchy/shell.toml`** (`font.base-size = 12`),
  **`shell.json`** — bar tuning.
- Web apps / desktop entries in `~/.local/share/applications/` (copied to
  `reference/omarchy/webapps/`): Discord, Google Photos, Docker, Disk Usage,
  omamail, plus handlers for foot/imv/mpv/claude-code.

## Personal tools pulled in (not from any distro repo)

| Tool | Source | Role |
|---|---|---|
| `clipboard-manager-ms` | `github.com/mutantsan/clipboard-manager` (cargo build → `~/.cargo/bin`) | `SUPER+V` clipboard history TUI |
| `omarchy-sc` | `github.com/mutantsan/omarchy-sc` | menu suggestion control |
| `solr-status` | `github.com/mutantsan/solr-status` | bar plugin |
| `tempie` | (`~/pet/tempie`) | time logging CLI, aliased in dotfiles |

## Custom Basecamp packages (Arch-only, need Nix equivalents or drop)

From `omarchy-base.packages`: `aether`, `herdr`, `omacalc`, `omacut`, `omawrite`,
`omarchy-nvim`, `tensaku`, `cliamp`, `tobi-try`, `ttfx`, `ttfx`, `omamail`, `usage`.
nixarchy vendors the Omarchy tree so most of these come along; anything it can't
build fails gracefully with a message rather than breaking the menu.

## Enabled user services

`bt-agent`, `omarchy-crash-watch`, `omarchy-fcitx5`, `omarchy-migrate-notify`,
`omarchy-recover-internal-monitor`, `omarchy-sleep-lock`, `tmux.service`,
`pipewire*`, `wireplumber`, `gnome-keyring`, `xdg-user-dirs`.
