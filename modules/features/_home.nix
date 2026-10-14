{ config, pkgs, ... }:

let
  # Jira time tracking CLI, from crates.io (not in nixpkgs). To update: bump
  # version, blank both hashes, rebuild and paste the hashes Nix reports.
  tempie = pkgs.rustPlatform.buildRustPackage rec {
    pname = "tempie";
    version = "0.11.1";

    src = pkgs.fetchCrate {
      inherit pname version;
      hash = "sha256-QWScv/t8OCCWAozDPcwERb1RRadnI2CdXR6aIxgNv1U=";
    };

    cargoHash = "sha256-nSTs6dNT91T2C9tsIXXgiLvpHMGJ5gsnRZrFUVN/O98=";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.openssl ];
  };

  # VS Code colour theme "Noctalia". The extension is only a manifest: its
  # theme file is a link to the JSON that Noctalia's vscode template
  # (hyprland.nix) renders, so the colours change without a rebuild.
  noctaliaVscodeTheme = pkgs.vscode-utils.buildVscodeExtension {
    pname = "noctalia-theme";
    version = "1.0.0";
    vscodeExtPublisher = "noctalia";
    vscodeExtName = "theme";
    vscodeExtUniqueId = "noctalia.theme";
    sourceRoot = "noctalia-vscode-theme-src"; # the default expects an unpacked .vsix
    src = pkgs.runCommand "noctalia-vscode-theme-src" { } ''
      mkdir -p $out/themes
      cp ${pkgs.writeText "package.json" (builtins.toJSON {
        name = "theme";
        publisher = "noctalia";
        displayName = "Noctalia";
        version = "1.0.0";
        engines.vscode = "*";
        contributes.themes = [{
          label = "Noctalia";
          uiTheme = "vs-dark";
          path = "./themes/noctalia.json";
          # Undocumented: VS Code watches the theme file and re-applies it
          # when Noctalia rewrites it.
          _watch = true;
        }];
      })} $out/package.json
      ln -s ${config.xdg.cacheHome}/noctalia/vscode-theme.json $out/themes/noctalia.json
    '';
    # The link target only exists in the home directory.
    dontCheckForBrokenSymlinks = true;
  };
in

{
  home.packages = [
    pkgs.eza
    pkgs.bat
    pkgs.jq
    pkgs.rustup
    pkgs.uv
    pkgs.nodejs
    pkgs.fnm
    pkgs.telegram-desktop
    pkgs.slack
    pkgs.dbgate # community edition (MIT)
    pkgs.libreoffice
    pkgs.proton-pass
    pkgs.proton-pass-cli
    pkgs.obs-studio
    pkgs.qbittorrent
    pkgs.tmux
    pkgs.gettext # envsubst, for initckan
    pkgs.gcc # C compiler for Python sdists such as psycopg2
    pkgs.libpq.pg_config # psycopg2 build needs pg_config
    pkgs.docker-sbx # sbx, Docker's sandbox CLI for agents
    tempie

    # Neovim: language servers, formatters and the parser compiler. The config
    # expects them on PATH instead of downloading them with Mason.
    pkgs.tree-sitter # CLI, nvim-treesitter builds parsers with it
    pkgs.lua-language-server
    pkgs.stylua
    pkgs.nixd
    pkgs.nixfmt
    pkgs.basedpyright
    pkgs.ruff
  ];

  home.file = {
    # XDG default-terminal spec (xdg-terminal-exec and terminal-aware apps
    # read this to pick a terminal emulator).
    ".config/xdg-terminals.list".text = ''
      com.mitchellh.ghostty.desktop
    '';
  };

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      font-family = "FiraCode Nerd Font";
      font-size = 13;
      cursor-style = "block";
      cursor-style-blink = false;
      # ~/.config/ghostty/themes/noctalia, written by Noctalia's ghostty theme
      # template (hyprland.nix).
      theme = "noctalia";
      keybind = [
        "performable:ctrl+c=copy_to_clipboard"
        "ctrl+v=paste_from_clipboard"
        # Ghostty's command palette, split-down and inspector; freed so Neovim
        # gets the keys.
        "ctrl+shift+p=unbind"
        "ctrl+shift+e=unbind"
        "ctrl+shift+i=unbind"
      ];
    };
  };

  # Mouse cursor. Hyprland gets the theme name from ~/.config/uwsm/env
  # (hyprland.nix).
  home.pointerCursor = {
    package = pkgs.kdePackages.breeze;
    name = "breeze_cursors";
    size = 24;
    hyprcursor.enable = true;
    gtk.enable = true;
  };

  # GTK theme, icons and fonts. Written to gtk-3.0/gtk-4.0 settings.ini and to
  # dconf, which is what the portal and Electron apps read.
  gtk = {
    enable = true;
    colorScheme = "dark";

    # GTK3 port of libadwaita; also themes Electron menu bars.
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    # The font itself comes from fonts.packages in desktop.nix.
    font = {
      name = "Noto Sans";
      size = 10;
    };

    # No GTK2 apps here; skip ~/.gtkrc-2.0.
    gtk2.enable = false;

    # libadwaita is dark through colorScheme alone. With this stateVersion the
    # option would otherwise inherit gtk.theme and import adw-gtk3 as user CSS.
    gtk4.theme = null;

    # Colours come from Noctalia's gtk3/gtk4 theme templates (hyprland.nix),
    # which write noctalia.css next to gtk.css whenever the palette or the
    # dark/light mode changes. The import has to be declared here: gtk.css is a
    # store symlink, and the template would otherwise replace it with a file.
    gtk3.extraCss = ''@import url("noctalia.css");'';
    gtk4.extraCss = ''@import url("noctalia.css");'';
  };

  dconf.settings."org/gnome/desktop/interface" = {
    document-font-name = "Noto Sans 10";
    monospace-font-name = "JetBrainsMono Nerd Font 10";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "ghostty";
    # Syntax colours from the terminal's palette, which Noctalia sets through
    # its ghostty template; wins over the themes named in bat's config.
    BAT_THEME = "ansi";
  };

  programs.zsh.enable = true;
  # EDITOR=nvim would otherwise make zsh pick the vi keymap.
  programs.zsh.defaultKeymap = "emacs";

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Starship's config lives in ~/dotfiles, shared with the other machines.
  # Here zsh uses Noctalia's themed copy of it instead (see initContent).
  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/starship/.config/starship.toml";

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # Alt-C: fuzzy-cd into any dir under $HOME (not just from $PWD)
    changeDirWidgetCommand = ''
      fd -t d --follow \
        -E .git \
        -E .direnv \
        -E node_modules \
        -E __pycache__ \
        -E .cargo \
        -E .nvm \
        -E .npm \
        -E .pyenv \
        -E .ipython \
        -E .cache \
        -E .vscode \
        -E .rustup \
        -E .steam \
        -E go/pkg/ \
        . "$HOME"
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  # Atuin's config lives in ~/dotfiles, shared with the other machines. The
  # theme it names, themes/noctalia.toml, is written by Noctalia's atuin
  # template (hyprland.nix).
  xdg.configFile."atuin/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/atuin/.config/atuin/config.toml";

  # bat's config lives in ~/dotfiles, shared with the other machines.
  xdg.configFile."bat/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/bat/.config/bat/config";

  # Neovim's config lives in ~/dotfiles, shared with the other machines. The
  # whole directory is linked, so lazy.nvim can write lazy-lock.json into it.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";

  # Noctalia's settings GUI writes its overrides to settings.toml, layered on
  # top of the config.toml from hyprland.nix. The file lives in
  # ~/dotfiles as a plain, writable file; Noctalia writes through the symlink.
  xdg.stateFile."noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/noctalia/.local/state/noctalia/settings.toml";

  # tmux.conf lives in ~/dotfiles as a plain file (shared with the Mac, where
  # TPM loads the plugins). Here the plugins come from nixpkgs via plugins.conf,
  # which the dotfiles config sources at its end.
  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/tmux/.config/tmux/tmux.conf";
  xdg.configFile."tmux/plugins.conf".text = ''
    run-shell ${pkgs.tmuxPlugins.resurrect.rtp}
    run-shell ${pkgs.tmuxPlugins.continuum.rtp}
  '';

  # Detached tmux server, started at login. Stopping it saves the sessions
  # with resurrect first.
  systemd.user.services.tmux = {
    Unit = {
      Description = "tmux default session (detached)";
      Documentation = "man:tmux(1)";
      # Start once UWSM has exported the session environment, so the panes get
      # WAYLAND_DISPLAY and friends; without them GUI apps started from a pane
      # fall back to XWayland and miss the window rules.
      After = [ "graphical-session.target" ];
      # A rebuild must not kill the running sessions.
      X-RestartIfChanged = false;
    };
    Service = {
      Type = "forking";
      ExecStart = "${pkgs.tmux}/bin/tmux new-session -d";
      ExecStop = [
        "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"
        "${pkgs.tmux}/bin/tmux kill-server"
      ];
      KillMode = "none";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix # Nix Language Support
        ms-python.python
        ms-python.debugpy
        ms-python.vscode-python-envs
        charliermarsh.ruff # Ruff
        tamasfe.even-better-toml # Even Better Toml
        arcticicestudio.nord-visual-studio-code # Nord Theme
        samuelcolvin.jinjahtml # Better Jinja
      ] ++ [ noctaliaVscodeTheme ];
    };
  };

  # VS Code settings and keybindings live in ~/dotfiles as plain, writable JSON
  # (shared with the Mac), so the editor's own UI can save to them.
  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/vscode/.config/Code/User/settings.json";
  xdg.configFile."Code/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/vscode/.config/Code/User/keybindings.json";

  programs.git = {
    enable = true;

    settings.user.name = "Oleksandr Cherniavskyi";
    settings.user.email = "kvaqich@gmail.com";
    settings.credential.helper = "cache --timeout=86400";
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.zsh.initContent = ''
    # /etc/zshrc binds Home/End/Insert/Delete from terminfo before the
    # keymap switches to emacs, so they land in viins (EDITOR=nvim). Bind
    # them again in the keymap that is actually used.
    source /etc/zinputrc

    # Word motions/deletes (Alt-Backspace, Alt-B/F/D) stop at punctuation, as
    # in bash, instead of treating a whole path as one word.
    WORDCHARS=""

    # Tab completion: try a prefix match first, then fall back to matching
    # anywhere in the name (`cd tab<TAB>` -> ckanext-tables).
    zstyle ':completion:*' matcher-list ''' 'l:|=* r:|=*'

    # fzf colours from Noctalia's fzf template (hyprland.nix). fzf refuses to
    # start if the file is missing, as it is until the first render.
    [[ -r "$HOME/.config/fzf/noctalia" ]] && export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/noctalia"

    # Starship colours from Noctalia's starship template (hyprland.nix); the
    # ~/dotfiles config is the fallback until the first render.
    [[ -r "$HOME/.cache/noctalia/starship.toml" ]] && export STARSHIP_CONFIG="$HOME/.cache/noctalia/starship.toml"

    # The template's hook sends SIGUSR1 to the shells registered here, so the
    # prompt on screen is redrawn in the new colours.
    TRAPUSR1() { zle && zle reset-prompt }
    _prompt_pidfile="''${XDG_RUNTIME_DIR:-/run/user/$UID}/zsh-prompts/$$"
    mkdir -p "''${_prompt_pidfile:h}" && : > "$_prompt_pidfile"
    _prompt_unregister() { rm -f "$_prompt_pidfile" }
    autoload -Uz add-zsh-hook && add-zsh-hook zshexit _prompt_unregister

    # No home-manager module for fnm exists yet; hook it manually.
    eval "$(fnm env --use-on-cd --shell zsh)"

    # Aliases and shell functions live in ~/dotfiles as plain shell files,
    # shared with the other machines (stowed to ~/.config/bash there).
    export MY_CONF_DIR="$HOME/dotfiles" # initckan reads templates/ckan.ini from it
    for _f in "$HOME/dotfiles/bash/.config/bash/"*.sh(N); do
      [[ -r "$_f" ]] && source "$_f"
    done
    unset _f
  '';
}
