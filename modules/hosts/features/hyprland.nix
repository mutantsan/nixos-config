# Hyprland with the look, input and keybindings of the Omarchy machine.
#
# The compositor config is plain Lua in ./_hypr (Hyprland >= 0.55), ported from
# Omarchy 4.0.4's defaults plus the personal overrides. Omarchy's own shell is
# not here: Waybar, Vicinae (plus Fuzzel for the small pickers), Mako, Hyprlock
# and Hypridle stand in for its bar, menu, notifications and lock screen, and the hypr-* scripts below replace the
# omarchy-* commands the bindings used to call.
{ ... }: {
  flake.nixosModules.hyprland = { pkgs, lib, ... }:
    let
      # Nord, the theme active on the Omarchy machine. Hex without the leading #.
      colors = {
        background = "2e3440";
        surface = "3b4252";
        selection = "434c5e";
        muted = "4c566a";
        foreground = "d8dee9";
        accent = "81a1c1";
        red = "bf616a";
      };

      font = "JetBrainsMono Nerd Font";

      apps = {
        terminal = "ghostty";
        browser = "firefox";
        browser_private = "firefox --private-window";
        files = "nautilus --new-window";
        editor = "code";
        dropdown_terminal = "ghostty --class=special.terminal";
      };

      # Under the Lua config, hyprctl only accepts Lua dispatchers
      # (hl.dsp.*), not the classic "dispatch <name> <args>" form.
      scripts = {
        screenshot = pkgs.writeShellApplication {
          name = "hypr-screenshot";
          runtimeInputs = with pkgs; [ grim slurp wl-clipboard libnotify procps coreutils ];
          text = ''
            dir="$HOME/Pictures/Screenshots"
            mkdir -p "$dir"

            # A second press while selecting cancels.
            if pkill -x slurp; then
              exit 0
            fi

            file="$dir/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"

            if [ "''${1:-region}" = "screen" ]; then
              grim "$file"
            else
              region=$(slurp) || exit 0
              grim -g "$region" "$file"
            fi

            wl-copy --type image/png <"$file"
            notify-send -t 3000 -i "$file" "Screenshot saved" "$file"
          '';
        };

        powerMenu = pkgs.writeShellApplication {
          name = "hypr-power-menu";
          runtimeInputs = with pkgs; [ fuzzel coreutils ];
          text = ''
            choice=$(printf '%s\n' "Lock" "Suspend" "Log out" "Restart" "Shut down" |
              fuzzel --dmenu --lines 5 --width 20 --prompt "System  ") || exit 0

            case "$choice" in
              "Lock") loginctl lock-session ;;
              "Suspend") systemctl suspend ;;
              "Log out") hyprctl dispatch 'hl.dsp.exit()' ;;
              "Restart") systemctl reboot ;;
              "Shut down") systemctl poweroff ;;
            esac
          '';
        };

        keybindings = pkgs.writeShellApplication {
          name = "hypr-keybindings";
          runtimeInputs = with pkgs; [ fuzzel jq ];
          text = ''
            hyprctl binds -j | jq -r '
              def mods: [ (if (.modmask / 64 | floor) % 2 == 1 then "SUPER" else empty end),
                          (if (.modmask / 4 | floor) % 2 == 1 then "CTRL" else empty end),
                          (if (.modmask / 8 | floor) % 2 == 1 then "ALT" else empty end),
                          (if .modmask % 2 == 1 then "SHIFT" else empty end) ];
              .[]
              | select(.has_description and .description != "" and .key != "")
              | "\((mods + [.key | ascii_upcase]) | join(" + "))  →  \(.description)"
            ' | fuzzel --dmenu --lines 20 --width 70 --prompt "Keybindings  " >/dev/null || true
          '';
        };

        nightlight = pkgs.writeShellApplication {
          name = "hypr-nightlight";
          runtimeInputs = with pkgs; [ hyprsunset libnotify procps gnugrep coreutils util-linux ];
          text = ''
            current() {
              hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+' | head -n1 || true
            }

            if ! pgrep -x hyprsunset >/dev/null; then
              setsid -f hyprsunset >/dev/null 2>&1
              sleep 0.5
            fi

            temp=$(current)
            if [ -z "$temp" ] || [ "$temp" -ge 6000 ]; then
              target=4000
              label="on"
            else
              target=6500
              label="off"
            fi

            # A freshly started hyprsunset applies its default at the end of its
            # boot, overriding anything set before then, so resend until it sticks.
            for _ in 1 2 3 4 5 6 7 8 9 10; do
              hyprctl hyprsunset temperature "$target" >/dev/null 2>&1 || true
              sleep 0.2
              if [ "$(current)" = "$target" ]; then
                break
              fi
            done

            notify-send -t 2000 "Night light $label"
          '';
        };

        idleToggle = pkgs.writeShellApplication {
          name = "hypr-idle-toggle";
          runtimeInputs = with pkgs; [ hypridle libnotify procps util-linux ];
          text = ''
            if pkill -x hypridle; then
              notify-send -t 2000 "Locking on idle off"
            else
              setsid -f hypridle >/dev/null 2>&1
              notify-send -t 2000 "Locking on idle on"
            fi
          '';
        };

        # SUPER + V. Uses clipboard-manager-ms (github.com/mutantsan/clipboard-manager,
        # built with cargo) when it is installed, and cliphist + fuzzel otherwise.
        clipboard = pkgs.writeShellApplication {
          name = "hypr-clipboard";
          runtimeInputs = with pkgs; [ cliphist fuzzel wl-clipboard coreutils ];
          text = ''
            bin="$HOME/.cargo/bin/clipboard-manager-ms"

            if [ "''${1:-}" = "--daemon" ]; then
              if [ -x "$bin" ]; then
                exec "$bin"
              fi
              exit 0
            fi

            if [ -x "$bin" ]; then
              # Single-instance guard: refocus an already open clipboard window.
              lock="''${XDG_DATA_HOME:-$HOME/.local/share}/clipboard-manager/ui.lock"
              if [ -f "$lock" ] && kill -0 "$(cat "$lock")" 2>/dev/null; then
                hyprctl dispatch 'hl.dsp.focus({ window = "class:floating.clipboard" })' >/dev/null
                exit 0
              fi

              exec ${apps.terminal} --class=floating.clipboard --title="Clipboard Manager" -e "$bin" --ui
            fi

            selection=$(cliphist list | fuzzel --dmenu --width 70 --prompt "Clipboard  ") || exit 0
            printf '%s' "$selection" | cliphist decode | wl-copy
          '';
        };

        # F1. Respawns the terminal if it was closed, so F1 always brings one back.
        dropdownTerminal = pkgs.writeShellApplication {
          name = "hypr-dropdown-terminal";
          runtimeInputs = with pkgs; [ jq coreutils util-linux ];
          text = ''
            has_window() {
              hyprctl clients -j | jq -e 'any(.[]; .class == "special.terminal")' >/dev/null
            }

            if ! has_window; then
              setsid -f ${apps.dropdown_terminal} >/dev/null 2>&1

              # Wait briefly for the window rules to park it on special:terminal.
              for _ in $(seq 1 40); do
                if has_window; then
                  break
                fi
                sleep 0.05
              done
            fi

            hyprctl dispatch 'hl.dsp.workspace.toggle_special("terminal")' >/dev/null
          '';
        };

        closeAllWindows = pkgs.writeShellApplication {
          name = "hypr-close-all-windows";
          runtimeInputs = with pkgs; [ jq ];
          text = ''
            hyprctl clients -j | jq -r '.[].address' | while read -r addr; do
              hyprctl dispatch "hl.dsp.window.close({ window = \"address:$addr\" })" >/dev/null
            done
          '';
        };

        # Uses ~/Pictures/Wallpapers/wallpaper.* when present, a flat color otherwise.
        wallpaper = pkgs.writeShellApplication {
          name = "hypr-wallpaper";
          runtimeInputs = with pkgs; [ swaybg ];
          text = ''
            for file in "$HOME"/Pictures/Wallpapers/wallpaper.*; do
              if [ -f "$file" ]; then
                exec swaybg -m fill -i "$file"
              fi
            done

            exec swaybg -c "#${colors.background}"
          '';
        };
      };
    in
    {
      programs.hyprland.enable = true;

      # hyprlock cannot check the password without its own PAM service.
      security.pam.services.hyprlock = { };

      # Automounting removable drives (udiskie).
      services.udisks2.enable = true;

      environment.systemPackages = (builtins.attrValues scripts) ++ (with pkgs; [
        hypridle
        hyprsunset
        hyprpicker
        hyprpolkitagent
        swaybg
        grim
        slurp
        wl-clipboard
        cliphist
        libnotify
        brightnessctl
        playerctl
        wireplumber
        udiskie
        nautilus
        pavucontrol
      ]);

      home-manager.sharedModules = [
        {
          # Each file is linked separately, so hyprlock.conf and settings.lua
          # can sit next to them.
          xdg.configFile."hypr" = {
            source = ./_hypr;
            recursive = true;
          };

          xdg.configFile."hypr/settings.lua".text = ''
            -- Generated by hyprland.nix.
            return {
              colors = {
                active_border = "rgb(${colors.accent})",
                inactive_border = "rgba(595959aa)",
              },

              apps = {
                terminal = "${apps.terminal}",
                browser = "${apps.browser}",
                browser_private = "${apps.browser_private}",
                files = "${apps.files}",
                editor = "${apps.editor}",
                dropdown_terminal = "${apps.dropdown_terminal}",
              },

              polkit_agent = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent",
            }
          '';

          # SUPER + SPACE launcher. Its server is started from _hypr/autostart.lua
          # (see the note on Waybar below), so the systemd unit stays off. Its
          # settings.json is linked from ~/dotfiles in the host's _home.nix.
          programs.vicinae = {
            enable = true;
          };

          # Still behind the dmenu-style pickers (power menu, keybindings, clipboard).
          programs.fuzzel = {
            enable = true;
            settings = {
              main = {
                font = "${font}:size=13";
                terminal = "${apps.terminal} -e";
                lines = 10;
                width = 40;
                horizontal-pad = 20;
                vertical-pad = 14;
                inner-pad = 8;
              };
              colors = {
                background = "${colors.background}ff";
                text = "${colors.foreground}ff";
                prompt = "${colors.accent}ff";
                input = "${colors.foreground}ff";
                match = "${colors.accent}ff";
                selection = "${colors.selection}ff";
                selection-text = "${colors.foreground}ff";
                selection-match = "${colors.accent}ff";
                border = "${colors.accent}ff";
              };
              border = {
                width = 2;
                radius = 0;
              };
            };
          };

          services.mako = {
            enable = true;
            settings = {
              font = "${font} 11";
              anchor = "top-right";
              width = 420;
              margin = "20";
              padding = "10";
              border-size = 2;
              border-radius = 0;
              max-icon-size = 32;
              default-timeout = 5000;
              background-color = "#${colors.background}";
              text-color = "#${colors.foreground}";
              border-color = "#${colors.accent}";

              "urgency=critical" = {
                border-color = "#${colors.red}";
                default-timeout = 0;
              };

              # SUPER + CTRL + comma.
              "mode=do-not-disturb" = {
                invisible = 1;
              };
            };
          };

          programs.hyprlock = {
            enable = true;
            settings = {
              general = {
                ignore_empty_input = true;
              };

              animations = {
                enabled = false;
              };

              background = [
                {
                  monitor = "";
                  color = "rgb(${colors.background})";
                }
              ];

              input-field = [
                {
                  monitor = "";
                  size = "650, 100";
                  position = "0, 0";
                  halign = "center";
                  valign = "center";

                  inner_color = "rgb(${colors.background})";
                  outer_color = "rgb(${colors.accent})";
                  outline_thickness = 4;

                  font_family = font;
                  font_color = "rgb(${colors.foreground})";

                  placeholder_text = "Enter Password";
                  check_color = "rgb(${colors.accent})";
                  fail_color = "rgb(${colors.red})";
                  fail_text = "<i>$FAIL ($ATTEMPTS)</i>";

                  rounding = 0;
                  shadow_passes = 0;
                  fade_on_empty = false;
                }
              ];
            };
          };

          # Started from _hypr/autostart.lua rather than systemd: without UWSM
          # nothing activates graphical-session.target.
          programs.waybar = {
            enable = true;
            settings.mainBar = {
              layer = "top";
              position = "top";
              height = 26;
              spacing = 0;

              modules-left = [ "hyprland/workspaces" ];
              modules-center = [ "clock" ];
              modules-right = [
                "tray"
                "hyprland/language"
                "bluetooth"
                "network"
                "pulseaudio"
                "cpu"
              ];

              "hyprland/workspaces" = {
                format = "{id}";
                persistent-workspaces = {
                  "1" = [ ];
                  "2" = [ ];
                  "3" = [ ];
                  "4" = [ ];
                  "5" = [ ];
                };
              };

              clock = {
                format = "{:%A %H:%M}";
                format-alt = "{:%d %B W%V %Y}";
                tooltip = false;
              };

              tray = {
                icon-size = 12;
                spacing = 12;
              };

              "hyprland/language" = {
                format = "{short}";
              };

              bluetooth = {
                format = "󰂯";
                format-disabled = "󰂲";
                format-connected = "󰂯";
                tooltip-format = "Devices connected: {num_connections}";
                on-click = "blueman-manager";
              };

              network = {
                format-wifi = "󰖩";
                format-ethernet = "󰈀";
                format-disconnected = "󰖪";
                tooltip-format-wifi = "{essid} ({signalStrength}%)";
                tooltip-format-ethernet = "{ifname} {ipaddr}";
                tooltip-format-disconnected = "Disconnected";
                interval = 3;
              };

              pulseaudio = {
                format = "{icon}";
                format-muted = "󰖁";
                format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
                tooltip-format = "Volume {volume}%";
                scroll-step = 5;
                on-click = "pavucontrol";
                on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              };

              cpu = {
                interval = 5;
                format = "󰍛";
                on-click = "${apps.terminal} -e btop";
              };
            };

            style = ''
              * {
                background-color: #${colors.background};
                color: #${colors.foreground};
                border: none;
                border-radius: 0;
                min-height: 0;
                font-family: "${font}";
                font-size: 12px;
              }

              .modules-left {
                margin-left: 8px;
              }

              .modules-right {
                margin-right: 8px;
              }

              #workspaces button {
                all: initial;
                padding: 0 6px;
                margin: 0 1.5px;
                min-width: 9px;
                color: #${colors.foreground};
              }

              #workspaces button.empty {
                opacity: 0.5;
              }

              #workspaces button.active {
                color: #${colors.accent};
              }

              #tray,
              #language,
              #bluetooth,
              #network,
              #pulseaudio,
              #cpu {
                min-width: 12px;
                margin: 0 7.5px;
              }

              tooltip {
                padding: 2px;
                border: 1px solid #${colors.accent};
              }
            '';
          };
        }
      ];
    };
}
