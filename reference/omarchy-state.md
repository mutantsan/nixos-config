# Omarchy state snapshot — source machine

Captured 2026-10-11 (first pass 2026-09-10) from the current Omarchy install, to
be reproduced on the NixOS machine. This is reference material, not config that
gets applied.

## System

| | |
|---|---|
| Distro | Omarchy 4.0.4-1 (`omarchy-zsh` 1.5.0-2, `omarchy-nvim` 2026.8.13-1) |
| Base | Arch (`ID_LIKE=arch`), kernel `linux-omarchy` 7.2.5-3 |
| WM | Hyprland, configured via the **Lua API** (`hl.*` / `o.*` DSL, needs Hyprland ≥ 0.55) |
| Bar / shell | **QuickShell**-based (`quickshell`, `herdr`, `gtk4-layer-shell`) — *not* waybar |
| Theme engine | `aether` |
| Active theme | **flexoki-light**, background `1-orb.png` (see `state/current.txt`) |
| Login | SDDM |
| Display scale | monitor `scale = 1.25`, `GDK_SCALE = 1` |
| Keyboard | `kb_layout = us,ua`; `kb_options = grp:caps_toggle,compose:ralt` (Caps switches layout, Right Alt is Compose) |
| Audio | PipeWire + WirePlumber + `pipewire-pulse` |
| GPU | Intel iGPU primary, NVIDIA Quadro secondary — see "GPU" below |
| Input remap | none on this machine: `/etc/keyd` does not exist. `dotfiles/etc/keyd/default.conf` is not applied here. |
| AUR / foreign pkgs | only `docker-sbx` |
| Explicit pkgs | 190 (see `packages-explicit.txt`) |
| Enabled services | `services-system.txt`, `services-user.txt` |

## The defaults themselves

`omarchy-4.0.4-defaults.tar.zst` holds `/usr/share/omarchy/{default,shell,bin,config,version}`
and `/usr/share/omarchy-zsh` exactly as installed. The personal files below are a
thin layer over these, so this is what to diff against if nixarchy's vendored
tree (pinned `v4.0.3-1`) behaves differently. Themes are left out (119 MB,
available upstream at github.com/basecamp/omarchy).

`keybindings.txt` is the resolved binding list (`omarchy menu keybindings --print`),
defaults and overrides merged.

## Personal Hyprland overrides (`~/.config/hypr/*.lua`)

Copied verbatim into `hypr/`. These are the layer to re-create on NixOS.

- **monitors.lua** — `scale = 1.25`, `GDK_SCALE = 1`.
- **input.lua** — dual layout `us,ua`, Caps toggles layout, Right Alt is Compose.
- **bindings.lua** —
  - `SUPER+V` → clipboard-manager (`scripts/clipboard-manager-trigger.sh`)
  - `F1` → toggle special `terminal` workspace (drop-down terminal)
  - `SUPER+SHIFT+S` → `omarchy-capture-screenshot` (was Google Maps webapp)
  - Hey bindings removed: `SUPER+SHIFT+E`, `SUPER+SHIFT+ALT+E`, `SUPER+SHIFT+C`
- **hyprland.lua** — VS Code and Zed always on workspace 1; float rule for the
  clipboard-manager TUI; drop-down terminal parked on `special:terminal`, which
  uses the scrolling layout; opacity forced to 1 for all windows;
  `__GLX_VENDOR_LIBRARY_NAME=mesa`.
- **looknfeel.lua** — no animation on the special workspace; `focus_on_activate = false`.
- **autostart.lua** — spawns the `clipboard-manager-ms` daemon and the drop-down
  terminal, now **foot** (`foot --app-id=special.terminal`), not Ghostty.

### State that lives outside `~/.config`

- `state/workspace-layouts/` — from `~/.local/state/omarchy/workspace-layouts/`:
  workspaces 1 and 4 use the scrolling layout, 2, 3 and 5 dwindle.
- `state/current.txt` — theme, background, default editor (`code`), default agent (`claude`).
- `~/.local/state/omarchy/toggles/hypr/flags.lua` holds no flags.

## GPU

The monitor is plugged into the motherboard, so the desktop renders on the Intel
iGPU and the NVIDIA card is secondary. Three pieces, all captured here:

- `uwsm/default` — `AQ_DRM_DEVICES` lists Intel first; also sets
  `OMARCHY_SCREENSHOT_DIR=~/Pictures/Screenshots`.
- `hypr/gpu-symlinks.txt` — `~/.config/hypr/gpu-{intel,nvidia}` point at
  `/dev/dri/by-path` so the order survives card0/card1 renumbering.
- `hypr/hyprland.lua` — overrides Omarchy's NVIDIA default with `mesa`.

`notes/nvidia.md` has the reasoning and how to offload a single app to the
Quadro. On NixOS the equivalent is `hardware.nvidia.prime` with the same bus IDs
(Intel `0000:00:02.0`, NVIDIA `0000:02:00.0`).

## Glue scripts and units

- `scripts/dropdown-terminal.sh` — `~/.local/bin`; respawns the foot window if
  it was closed, then toggles the special workspace. Not bound at the moment
  (`F1` calls the dispatcher directly).
- `scripts/clipboard-manager-trigger.sh` — `~/.local/share/clipboard-manager/trigger.sh`,
  the `SUPER+V` target. Hardcodes `/home/cherry/.cargo/bin/clipboard-manager-ms`.
- `systemd/tmux.service` — user unit: detached tmux session at login, saves via
  tmux-resurrect on stop. Hardcodes `/usr/bin/tmux`.
- `home/XCompose` — includes Omarchy's emoji table plus name/email shortcuts.
- `home/mimeapps.list`, `home/xdg-terminals.list`, `home/chromium-flags.conf`.

## Configs changed from Omarchy's shipped copies

In `config/`, each a modified version of the file under `omarchy/config/` in the
tarball: `ghostty/config` (Liberation Mono 11, Ctrl+C/V copy-paste), `foot/foot.ini`,
`kitty/kitty.conf`, `alacritty/alacritty.toml`, `btop/btop.conf`. `herdr/config.toml`
is stock.

`git/config` and `mise/config.toml` are portable and live in the `dotfiles` repo
as stow packages instead.

## Omarchy customizations beyond hypr

- **`omarchy/omarchy-menu.jsonc`** — personal menu entries plus the entries
  hidden by `omarchy-sc` (github.com/mutantsan/omarchy-sc); the hidden list is
  also in `omarchy/omarchy-sc-hidden.json`.
- **`omarchy/shell.json`**, **`omarchy/shell.toml`** (`font.base-size = 14`),
  **`omarchy/keystroke.json`** — bar layout and plugin settings.
- **QuickShell plugins** (`~/.config/omarchy/plugins/`) — nine of them, with
  source repo and installed commit in `omarchy/plugins.txt`. `mutantsan.solr-status`
  is a symlink to `~/pet/solr-status`.
- Web apps / desktop entries from `~/.local/share/applications/` in
  `omarchy/webapps/`: Discord, Google Photos, Docker, Disk Usage, omamail, Zaku,
  plus handlers for foot/imv/mpv/claude-code.

## Shell

`~/.zshrc` (dotfiles) is layered on the `omarchy-zsh` package, not oh-my-zsh. It
sources `/usr/share/omarchy-zsh/shell/` when present and otherwise the verbatim
copy in `dotfiles/zsh/.config/zsh/omarchy-shell/`. That base expects `starship`,
`zoxide`, `fzf`, `mise`, `eza`, `bat`, `zsh-syntax-highlighting` and optionally
`zsh-autosuggestions` on the system.

## Personal tools pulled in (not from any distro repo)

| Tool | Source | Role |
|---|---|---|
| `clipboard-manager-ms` | `github.com/mutantsan/clipboard-manager` (cargo build → `~/.cargo/bin`) | `SUPER+V` clipboard history TUI |
| `omarchy-sc` | `github.com/mutantsan/omarchy-sc` | menu suggestion control |
| `solr-status` | `github.com/mutantsan/solr-status` | bar plugin |
| `tempie` | (`~/pet/tempie`) | time logging CLI, aliased in dotfiles |

## Custom Basecamp packages (Arch-only, need Nix equivalents or drop)

From `omarchy-base.packages`: `aether`, `herdr`, `omacalc`, `omacut`, `omawrite`,
`omarchy-nvim`, `tensaku`, `cliamp`, `tobi-try`, `ttfx`, `omamail`, `usage`.
nixarchy vendors the Omarchy tree so most of these come along; anything it can't
build fails gracefully with a message rather than breaking the menu.

## Not in any repo — back up separately

`~/.ssh`, `~/.local/share/atuin/key`, `~/.local/share/keyrings`, browser profiles.
