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
    pkgs.tmux
    pkgs.gettext # envsubst, for initckan
    pkgs.gcc # C compiler for Python sdists such as psycopg2
    pkgs.libpq.pg_config # psycopg2 build needs pg_config
    pkgs.docker-sbx # sbx, Docker's sandbox CLI for agents
    tempie
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
      font-size = 11;
      cursor-style = "block";
      cursor-style-blink = false;
      keybind = [
        "performable:ctrl+c=copy_to_clipboard"
        "ctrl+v=paste_from_clipboard"
      ];
    };
  };

  # Mouse cursor. Hyprland gets the theme name from _hypr/envs.lua.
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
  };

  dconf.settings."org/gnome/desktop/interface" = {
    document-font-name = "Noto Sans 10";
    monospace-font-name = "JetBrainsMono Nerd Font 10";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "ghostty";
  };

  programs.zsh.enable = true;
  # EDITOR=nvim would otherwise make zsh pick the vi keymap.
  programs.zsh.defaultKeymap = "emacs";

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Starship's config lives in ~/dotfiles, shared with the other machines.
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

  # Atuin's config and theme live in ~/dotfiles, shared with the other machines.
  xdg.configFile."atuin/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/atuin/.config/atuin/config.toml";
  xdg.configFile."atuin/themes/everforest.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/atuin/.config/atuin/themes/everforest.toml";

  # bat's config lives in ~/dotfiles, shared with the other machines.
  xdg.configFile."bat/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/bat/.config/bat/config";

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
      # A rebuild must not kill the running sessions.
      X-RestartIfChanged = false;
    };
    Service = {
      Type = "forking";
      Environment = "DISPLAY=:0";
      ExecStart = "${pkgs.tmux}/bin/tmux new-session -d";
      ExecStop = [
        "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"
        "${pkgs.tmux}/bin/tmux kill-server"
      ];
      KillMode = "none";
      RestartSec = 2;
    };
    Install.WantedBy = [ "default.target" ];
  };

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        ms-python.python
        ms-python.debugpy
        ms-python.vscode-python-envs
        charliermarsh.ruff
        tamasfe.even-better-toml
        arcticicestudio.nord-visual-studio-code
      ];
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
    # Word motions/deletes (Alt-Backspace, Alt-B/F/D) stop at punctuation, as
    # in bash, instead of treating a whole path as one word.
    WORDCHARS=""

    # Tab completion: try a prefix match first, then fall back to matching
    # anywhere in the name (`cd tab<TAB>` -> ckanext-tables).
    zstyle ':completion:*' matcher-list ''' 'l:|=* r:|=*'

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
