{ inputs, ... }: {
  flake.nixosModules.hyprland = { config, pkgs, lib, ... }:
    let
      # Nord; only shows until Noctalia's hyprland theme template has written
      # ~/.config/hypr/noctalia.lua (see _hypr/hyprland.lua).
      colors = {
        accent = "81a1c1";
      };

      font = "JetBrainsMono Nerd Font";

      # hyprctl has to come from the same build as the running compositor.
      hyprland = config.programs.hyprland.package;

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
        powerMenu = pkgs.writeShellApplication {
          name = "hypr-power-menu";
          runtimeInputs = with pkgs; [ coreutils ];
          text = ''
            choice=$(printf '%s\n' "Lock" "Suspend" "Log out" "Restart" "Shut down" |
              noctalia dmenu --prompt "System") || exit 0

            case "$choice" in
              "Lock") loginctl lock-session ;;
              "Suspend") systemctl suspend ;;
              # Stops the compositor and the session units together; a bare
              # hl.dsp.exit() would leave graphical-session.target behind.
              "Log out") uwsm stop ;;
              "Restart") systemctl reboot ;;
              "Shut down") systemctl poweroff ;;
            esac
          '';
        };

        keybindings = pkgs.writeShellApplication {
          name = "hypr-keybindings";
          runtimeInputs = with pkgs; [ hyprland jq ];
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
          runtimeInputs = with pkgs; [ coreutils gnugrep hyprland hyprsunset libnotify procps util-linux ];
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
          runtimeInputs = with pkgs; [ coreutils hyprland jq util-linux ];
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

        # Opens files in a new VS Code window on the current workspace instead
        # of workspace 1 (see o.code_here in _hypr/windows.lua).
        codeHere = pkgs.writeShellApplication {
          name = "hypr-code-here";
          runtimeInputs = [ hyprland ];
          text = ''
            hyprctl eval 'o.code_here()' >/dev/null || true
            exec code --new-window "$@"
          '';
        };

        closeAllWindows = pkgs.writeShellApplication {
          name = "hypr-close-all-windows";
          runtimeInputs = with pkgs; [ hyprland jq ];
          text = ''
            hyprctl clients -j | jq -r '.[].address' | while read -r addr; do
              hyprctl dispatch "hl.dsp.window.close({ window = \"address:$addr\" })" >/dev/null
            done
          '';
        };
      };

      # GTK4 parses ~/.config/gtk-4.0/gtk.css once, at startup, and parses it
      # again (re-reading the noctalia.css it imports) only when the
      # dark/light preference changes. Flip the preference and put it back, so
      # running apps such as Nautilus pick up a palette change.
      gtkReload = pkgs.writeShellApplication {
        name = "noctalia-gtk-reload";
        runtimeInputs = with pkgs; [ dconf ];
        text = ''
          key=/org/gnome/desktop/interface/color-scheme
          current=$(dconf read "$key")
          if [ "$current" = "'prefer-light'" ]; then
            other="'prefer-dark'"
          else
            current="'prefer-dark'"
            other="'prefer-light'"
          fi
          dconf write "$key" "$other"
          dconf write "$key" "$current"
        '';
      };

      # Starship prints truecolour codes, so a prompt already on screen keeps
      # the old colours. Interactive zsh shells register their PID and redraw
      # the prompt on SIGUSR1 (_home.nix); only those get the signal, as it
      # would kill a zsh running a script.
      starshipReload = pkgs.writeShellApplication {
        name = "noctalia-starship-reload";
        text = ''
          dir="''${XDG_RUNTIME_DIR:-/run/user/$UID}/zsh-prompts"
          [ -d "$dir" ] || exit 0
          for file in "$dir"/*; do
            [ -e "$file" ] || continue
            pid=''${file##*/}
            if [ "$(cat "/proc/$pid/comm" 2>/dev/null)" = zsh ]; then
              kill -USR1 "$pid" 2>/dev/null || true
            else
              rm -f "$file"
            fi
          done
        '';
      };

      # Telegram reads its theme file only at startup, so a running one is
      # restarted when Noctalia's telegram template has changed the file: back
      # to a window if it had one, to the tray otherwise.
      telegramReload = pkgs.writeShellApplication {
        name = "noctalia-telegram-reload";
        runtimeInputs = [ pkgs.coreutils pkgs.procps hyprland config.programs.uwsm.package ];
        text = ''
          theme="''${XDG_CONFIG_HOME:-$HOME/.config}/telegram-desktop/themes/noctalia.tdesktop-theme"
          applied="''${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/telegram-theme.applied"
          running='(^|/)Telegram( |$)'

          cmp -s "$theme" "$applied" && exit 0
          mkdir -p "$(dirname "$applied")"
          cp "$theme" "$applied"

          pgrep -u "$UID" -f "$running" >/dev/null || exit 0

          args=(-startintray)
          clients=$(hyprctl clients -j)
          if [[ "$clients" == *'"class": "org.telegram.desktop"'* ]]; then
            args=()
          fi

          pkill -u "$UID" -f "$running" || true
          for _ in $(seq 50); do
            pgrep -u "$UID" -f "$running" >/dev/null || break
            sleep 0.1
          done

          # Its own systemd scope, not a child of the Noctalia service.
          uwsm app -- ${pkgs.telegram-desktop}/bin/Telegram "''${args[@]}" >/dev/null 2>&1 &
        '';
      };

      # DbGate applies a theme by copying it into settings.json when it's
      # picked, so a rewritten theme file alone changes nothing. Copy it there
      # too while Noctalia is the selected theme.
      dbgateApply = pkgs.writeShellApplication {
        name = "noctalia-dbgate-apply";
        runtimeInputs = with pkgs; [ coreutils jq ];
        text = ''
          theme="$HOME/.dbgate/files/themes/Noctalia.json"
          settings="$HOME/.dbgate/settings.json"

          [ -f "$settings" ] || exit 0
          jq -e '.currentThemeDefinition.themeName == "Noctalia"' "$settings" >/dev/null || exit 0

          tmp=$(mktemp "$settings.XXXXXX")
          if jq --slurpfile theme "$theme" '.currentThemeDefinition = $theme[0]' "$settings" >"$tmp"; then
            mv "$tmp" "$settings"
          else
            rm -f "$tmp"
            exit 1
          fi
        '';
      };

      # Noctalia's IPC only answers once the shell is up, so retry for a while.
      caffeineEnable = pkgs.writeShellApplication {
        name = "noctalia-caffeine-enable";
        runtimeInputs = with pkgs; [ coreutils ];
        text = ''
          for _ in $(seq 30); do
            noctalia msg caffeine-enable && exit 0
            sleep 1
          done
          exit 1
        '';
      };
    in
    {
      options.my.hyprland.monitorScale = lib.mkOption {
        type = lib.types.number;
        default = 1;
        description = "Hyprland scale factor applied to every monitor.";
      };

      config = {
        # UWSM wraps the compositor in systemd units and activates
        # graphical-session.target, which the user services below hang off.
        programs.hyprland = {
          enable = true;
          withUWSM = true;
        };

        # The power key opens hypr-power-menu (_hypr/bindings/apps.lua); stop
        # logind from powering off on the same press.
        services.logind.settings.Login.HandlePowerKey = "ignore";

        # Automounting removable drives (udiskie).
        services.udisks2.enable = true;

        # Nautilus needs GVfs for trash://, network locations and MTP devices.
        services.gvfs.enable = true;

        # Codecs for Nautilus's audio/video properties tab. Its wrapper only
        # ships base and good; the wrapper prefixes, so these still apply.
        environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
          lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
            gst-plugins-base
            gst-plugins-good
            gst-plugins-bad
            gst-plugins-ugly
            gst-libav
          ]);

        # Text files opened from other apps go through hypr-code-here.
        xdg.mime.defaultApplications."text/plain" = "code-here.desktop";

        environment.systemPackages = (builtins.attrValues scripts) ++ [
          (pkgs.makeDesktopItem {
            name = "code-here";
            desktopName = "Visual Studio Code (current workspace)";
            exec = "hypr-code-here %F";
            icon = "vscode";
            noDisplay = true;
            mimeTypes = [ "text/plain" ];
          })
        ] ++ (with pkgs; [
          hyprpicker
          hyprsunset
          libnotify
          nautilus
          pavucontrol
          playerctl
          slurp
          udiskie
          wireplumber
          wl-clipboard
        ]);

        home-manager.sharedModules = [
          inputs.noctalia.homeModules.default
          {
            # Bar, notifications, launcher, clipboard, wallpaper, lock screen and
            # idle handling.
            programs.noctalia = {
              enable = true;
              systemd.enable = true;
              settings = {
                theme = {
                  mode = "dark";
                  source = "builtin";
                  builtin = "Nord";

                  # Apps that follow the shell's palette and dark/light mode.
                  # Each template writes a colour file into the app's config
                  # dir; the include that loads it is declared in this repo
                  # (_home.nix, _hypr/hyprland.lua), since those configs are
                  # read-only store symlinks the templates can't edit.
                  templates = {
                    enable_builtin_templates = true;
                    builtin_ids = [ "ghostty" "gtk3" "gtk4" "qt" ];

                    # Noctalia's own hyprland template, minus its hook: that one
                    # only appends the require() line and leaves the running
                    # compositor on the old colours.
                    user.hyprland = {
                      input_path = "${inputs.noctalia}/assets/templates/hyprland/hyprland.lua";
                      output_path = "~/.config/hypr/noctalia.lua";
                      post_hook = "${hyprland}/bin/hyprctl reload";
                    };

                    # CLI tools with no template of their own; the sources are
                    # in _noctalia/. bat and eza need none: they use the
                    # terminal's ANSI colours, which the ghostty template sets.
                    # fzf reads the file through FZF_DEFAULT_OPTS_FILE and nvim
                    # through its colorscheme setup in ~/dotfiles.
                    user.fzf = {
                      input_path = "${./_noctalia/fzf}";
                      output_path = "$XDG_CONFIG_HOME/fzf/noctalia";
                    };
                    # Selected by [theme] name in ~/dotfiles' atuin config.
                    user.atuin = {
                      input_path = "${./_noctalia/atuin.toml}";
                      output_path = "$XDG_CONFIG_HOME/atuin/themes/noctalia.toml";
                    };
                    user.nvim = {
                      input_path = "${./_noctalia/nvim.lua}";
                      output_path = "$XDG_DATA_HOME/nvim/noctalia.lua";
                      # Running instances reload the palette on SIGUSR1.
                      post_hook = "${pkgs.procps}/bin/pkill -USR1 -x nvim || true";
                    };
                    # A full copy of the ~/dotfiles starship config, not the
                    # builtin palette template, whose hook would edit that
                    # shared file. zsh points STARSHIP_CONFIG here (_home.nix);
                    # starship re-reads it on every prompt.
                    user.starship = {
                      input_path = "${./_noctalia/starship.toml}";
                      output_path = "$XDG_CACHE_HOME/noctalia/starship.toml";
                      post_hook = "${starshipReload}/bin/noctalia-starship-reload";
                    };
                    # Noctalia's community template, from
                    # api.noctalia.dev/templates/telegram. The theme has to be
                    # picked once in Telegram: Settings > Chat Settings >
                    # Choose from file.
                    user.telegram = {
                      input_path = "${./_noctalia/telegram.tdesktop-theme}";
                      output_path = "$XDG_CONFIG_HOME/telegram-desktop/themes/noctalia.tdesktop-theme";
                      post_hook = "${telegramReload}/bin/noctalia-telegram-reload";
                    };
                    # Theme file of the "Noctalia" VS Code extension built in
                    # _home.nix. The template is Noctalia's community one,
                    # from api.noctalia.dev/templates/vscode.
                    user.vscode = {
                      input_path = "${./_noctalia/vscode.json}";
                      output_path = "$XDG_CACHE_HOME/noctalia/vscode-theme.json";
                    };
                    # Listed in DbGate's theme picker as "Noctalia". Only the
                    # main UI variables are set; DbGate fills in the rest from
                    # its built-in dark or light theme.
                    user.dbgate = {
                      input_path = "${./_noctalia/dbgate.json}";
                      output_path = "~/.dbgate/files/themes/Noctalia.json";
                      post_hook = "${dbgateApply}/bin/noctalia-dbgate-apply";
                    };
                  };
                };

                # Fires once the templates above are written.
                hooks.colors_changed = "${gtkReload}/bin/noctalia-gtk-reload";

                shell = {
                  font_family = font;
                  animation.enabled = false;

                  # Login screen follows the shell's palette, dark/light mode
                  # and wallpaper (see the greeter in desktop.nix).
                  greeter_sync.auto_sync = true;

                  # Every screenshot opens the annotation editor first; Done
                  # (Enter) then saves the PNG and copies it to the clipboard.
                  screenshot = {
                    annotate = true;
                    directory = "~/Pictures/Screenshots";
                  };
                };

                # Weather location.
                location.address = "Cherkasy, Ukraine";

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

            # Caffeine on at login: Noctalia doesn't remember it and starts
            # with it off. PartOf re-runs this when Noctalia restarts.
            systemd.user.services.noctalia-caffeine = {
              Unit = {
                Description = "Enable Noctalia caffeine";
                After = [ "noctalia.service" ];
                PartOf = [ "noctalia.service" ];
              };
              Service = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "${caffeineEnable}/bin/noctalia-caffeine-enable";
              };
              Install.WantedBy = [ "noctalia.service" ];
            };

            services.hyprpolkitagent.enable = true;

            # Automounts removable drives; needs services.udisks2 above.
            services.udiskie = {
              enable = true;
              automount = true;
              notify = false;
              tray = "never";
            };

            # Session environment. UWSM loads these before the compositor and
            # hands them to systemd, so user services (and whatever Noctalia
            # launches) see them too; hl.env() only reaches Hyprland's own
            # children.
            xdg.configFile."uwsm/env".text = ''
              # Cursor theme (installed by home.pointerCursor) and size.
              export XCURSOR_THEME=breeze_cursors
              export XCURSOR_SIZE=24

              # Prefer Wayland, with X11 as the fallback.
              export GDK_BACKEND="wayland,x11,*"
              export QT_QPA_PLATFORM="wayland;xcb"
              export MOZ_ENABLE_WAYLAND=1
              export ELECTRON_OZONE_PLATFORM_HINT=wayland
              export OZONE_PLATFORM=wayland
              export NIXOS_OZONE_WL=1
            '';

            xdg.configFile."uwsm/env-hyprland".text = ''
              export HYPRCURSOR_THEME=breeze_cursors
              export HYPRCURSOR_SIZE=24
            '';

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

                monitor_scale = ${toString config.my.hyprland.monitorScale},
              }
            '';
          }
        ];
      };
    };
}
