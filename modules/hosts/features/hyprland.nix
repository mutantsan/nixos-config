{ inputs, ... }: {
  flake.nixosModules.hyprland = { pkgs, lib, ... }:
    let
      # Nord theme
      colors = {
        accent = "81a1c1";
      };

      font = "JetBrainsMono Nerd Font";

      apps = {
        terminal = "ghostty";
        browser = "chromium";
        browser_private = "chromium --incognito";
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
          runtimeInputs = with pkgs; [ coreutils ];
          text = ''
            choice=$(printf '%s\n' "Lock" "Suspend" "Log out" "Restart" "Shut down" |
              noctalia dmenu --prompt "System") || exit 0

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
          runtimeInputs = with pkgs; [ jq ];
          text = ''
            hyprctl binds -j | jq -r '
              def mods: [ (if (.modmask / 64 | floor) % 2 == 1 then "SUPER" else empty end),
                          (if (.modmask / 4 | floor) % 2 == 1 then "CTRL" else empty end),
                          (if (.modmask / 8 | floor) % 2 == 1 then "ALT" else empty end),
                          (if .modmask % 2 == 1 then "SHIFT" else empty end) ];
              .[]
              | select(.has_description and .description != "" and .key != "")
              | "\((mods + [.key | ascii_upcase]) | join(" + "))  →  \(.description)"
            ' | noctalia dmenu --prompt "Keybindings" >/dev/null || true
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
      };
    in
    {
      programs.hyprland.enable = true;

      # The power key opens hypr-power-menu (_hypr/bindings/apps.lua); stop
      # logind from powering off on the same press.
      services.logind.settings.Login.HandlePowerKey = "ignore";

      # Automounting removable drives (udiskie).
      services.udisks2.enable = true;

      environment.systemPackages = (builtins.attrValues scripts) ++ (with pkgs; [
        hyprsunset
        hyprpicker
        hyprpolkitagent
        grim
        slurp
        wl-clipboard
        libnotify
        playerctl
        wireplumber
        udiskie
        nautilus
        pavucontrol
      ]);

      home-manager.sharedModules = [
        inputs.noctalia.homeModules.default
        {
          # Bar, notifications, launcher, clipboard, wallpaper, lock screen and
          # idle handling. Started from _hypr/autostart.lua
          # rather than systemd: without UWSM nothing activates
          # graphical-session.target.
          programs.noctalia = {
            enable = true;
            settings = {
              theme = {
                mode = "dark";
                source = "builtin";
                builtin = "Nord";
              };

              shell = {
                font_family = font;
                animation.enabled = false;
              };

              # Lock after 5 minutes, screen off 30 seconds later, never
              # suspend. Locking before sleep is Noctalia's default.
              idle.behavior = {
                lock = {
                  enabled = true;
                  timeout = 300;
                  action = "lock";
                };
                screen-off = {
                  enabled = true;
                  timeout = 330;
                  action = "screen_off";
                };
              };

              bar.main = {
                position = "top";
                start = [ "workspaces" "sysmon" ];
                center = [ "clock" ];
                end = [ "tray" "notifications" "volume" "brightness" "wallpaper" "control-center" ];
              };
            };
          };

          # Each file is linked separately, so settings.lua can sit next to
          # them.
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
        }
      ];
    };
}
