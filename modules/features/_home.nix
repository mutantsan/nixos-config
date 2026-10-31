{ config, inputs, pkgs, ... }:

let
  # Configs shared with the other machines live in ~/dotfiles as plain files.
  # Linking them out of the store keeps them writable, so apps that save their
  # own settings (VS Code, lazy.nvim, Noctalia) write straight into the repo.
  dotfile = path:
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";

  # Jira time tracking CLI, from crates.io (not in nixpkgs). To update: bump
  # version, blank both hashes, rebuild and paste the hashes Nix reports.
  tempie = pkgs.rustPlatform.buildRustPackage rec {
    pname = "tempie";
    version = "0.11.2";

    src = pkgs.fetchCrate {
      inherit pname version;
      hash = "sha256-9LTVWHayPq8aQfAG3K+IibLSPMV/E2oP6tDL6GTLSr8=";
    };

    cargoHash = "sha256-GRkdc8eAhJ6TC0hVBZ5pKMAAILsd7RuEr3lFvY0ptnI=";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.openssl ];
  };

  # Use the maintained package from unstable while the system stays on stable.
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # Unity CLI (beta, not in nixpkgs): drives a running Unity Editor, used by the
  # Claude Code unity plugin. To update: take version and the linux-x64 sha256
  # from https://public-cdn.cloud.unity3d.com/hub/prod/cli/latest-beta.json.
  # It dlopens OpenSSL and GSSAPI at runtime, so those go on LD_LIBRARY_PATH.
  unity-cli = pkgs.stdenv.mkDerivation rec {
    pname = "unity-cli";
    version = "1.0.0-beta.13";

    src = pkgs.fetchurl {
      url = "https://public-cdn.cloud.unity3d.com/hub/prod/cli/${version}/unity-linux-x64";
      sha256 = "a84dace1f5e85b629fff841ddfc5ec8e97fd2a178242fca91c80bc5680142fb3";
    };

    dontUnpack = true;
    dontStrip = true; # single-file .NET bundle; stripping breaks it
    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];

    installPhase = ''
      install -Dm755 $src $out/bin/unity
      wrapProgram $out/bin/unity \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.openssl pkgs.krb5 pkgs.icu pkgs.zlib ]}
    '';
  };

  # UnityShaderCompiler links libtinfo.so.6. nixpkgs ncurses has that name only
  # as a symlink to libncursesw, and the FHS env's ldconfig indexes libraries by
  # SONAME, so the loader never finds it. Ship a copy carrying the right SONAME.
  libtinfo6 = pkgs.runCommand "libtinfo6" { nativeBuildInputs = [ pkgs.patchelf ]; } ''
    mkdir -p $out/lib
    cp ${pkgs.ncurses}/lib/libncursesw.so.6 $out/lib/libtinfo.so.6
    chmod +w $out/lib/libtinfo.so.6
    patchelf --set-soname libtinfo.so.6 $out/lib/libtinfo.so.6
  '';

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
  home.packages = with pkgs; [
    bat
    unstablePkgs.codex
    dbgate # community edition (MIT)
    discord
    docker-sbx # sbx, Docker's sandbox CLI for agents
    eza
    ffmpeg
    fnm
    gcc # C compiler for Python sdists such as psycopg2
    gettext # envsubst, for initckan
    jq
    libpq.pg_config # psycopg2 build needs pg_config
    libreoffice
    nodejs
    obs-studio
    proton-pass
    proton-pass-cli
    qbittorrent
    rustup
    slack
    telegram-desktop
    tempie
    tmux
    (unityhub.override { extraPkgs = _: [ libtinfo6 ]; })
    unity-cli
    uv

    # Neovim: language servers, formatters and the parser compiler. The config
    # expects them on PATH instead of downloading them with Mason.
    basedpyright
    lua-language-server
    nixd
    nixfmt
    ruff
    stylua
    tree-sitter # CLI, nvim-treesitter builds parsers with it
  ];

  # Default terminal for xdg-terminal-exec and terminal-aware apps.
  xdg.configFile."xdg-terminals.list".text = ''
    com.mitchellh.ghostty.desktop
  '';

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = "FiraCode Nerd Font";
      font-size = 13;
      app-notifications = "no-clipboard-copy";
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

  # Hyprland gets the theme name from ~/.config/uwsm/env (hyprland.nix).
  home.pointerCursor = {
    package = pkgs.kdePackages.breeze;
    name = "breeze_cursors";
    size = 24;
    hyprcursor.enable = true;
    gtk.enable = true;
  };

  # Written to gtk-3.0/gtk-4.0 settings.ini and to dconf, which is what the
  # portal and Electron apps read.
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

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # zsh uses Noctalia's themed copy of this instead (see initContent).
  xdg.configFile."starship.toml".source = dotfile "starship/.config/starship.toml";

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # Alt-C searches every directory under $HOME, not just under $PWD.
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

  # The theme it names, themes/noctalia.toml, is written by Noctalia's atuin
  # template (hyprland.nix).
  xdg.configFile."atuin/config.toml".source = dotfile "atuin/.config/atuin/config.toml";

  xdg.configFile."bat/config".source = dotfile "bat/.config/bat/config";

  # The whole directory is linked, so lazy.nvim can write lazy-lock.json into it.
  xdg.configFile."nvim".source = dotfile "nvim/.config/nvim";

  # Noctalia's settings GUI writes its overrides here, layered on top of the
  # config.toml from hyprland.nix.
  xdg.stateFile."noctalia/settings.toml".source =
    dotfile "noctalia/.local/state/noctalia/settings.toml";

  # On the Mac, TPM loads the tmux plugins. Here they come from nixpkgs via
  # plugins.conf, which the dotfiles config sources at its end.
  xdg.configFile."tmux/tmux.conf".source = dotfile "tmux/.config/tmux/tmux.conf";
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
    # Bakes _vscode/custom.css into the workbench stylesheet.
    # Updates checksum in product.json.
    package = pkgs.vscode.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.jq pkgs.openssl ];
      postInstall = (old.postInstall or "") + ''
        app=$out/lib/vscode/resources/app
        css=vs/workbench/workbench.desktop.main.css
        cat ${./_vscode/custom.css} >> $app/out/$css
        sum=$(openssl dgst -sha256 -binary $app/out/$css | base64 | tr -d '=')
        jq --arg f "$css" --arg s "$sum" '.checksums[$f] = $s' \
          $app/product.json > product.json
        mv product.json $app/product.json
      '';
    });
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        arcticicestudio.nord-visual-studio-code
        bbenoist.nix
        charliermarsh.ruff
        ms-python.debugpy
        ms-python.python
        ms-python.vscode-python-envs
        samuelcolvin.jinjahtml
        tamasfe.even-better-toml
      ] ++ [ noctaliaVscodeTheme ];
    };
  };

  xdg.configFile."Code/User/settings.json".source =
    dotfile "vscode/.config/Code/User/settings.json";
  xdg.configFile."Code/User/keybindings.json".source =
    dotfile "vscode/.config/Code/User/keybindings.json";

  programs.git = {
    enable = true;
    settings = {
      user.name = "Oleksandr Cherniavskyi";
      user.email = "kvaqich@gmail.com";
      credential.helper = "cache --timeout=86400";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.lazygit = {
    enable = true;
    settings.git.pagers = [{ pager = "delta --dark --paging=never"; }];
  };

  programs.zsh = {
    enable = true;
    # EDITOR=nvim would otherwise make zsh pick the vi keymap.
    defaultKeymap = "emacs";

    shellAliases.ff = "fastfetch";

    initContent = ''
      # /etc/zshrc binds Home/End/Insert/Delete from terminfo before the
      # keymap switches to emacs, so they land in viins (EDITOR=nvim). Bind
      # them again in the keymap that is actually used.
      source /etc/zinputrc

      # Word motions and deletes (Alt-Backspace, Alt-B/F/D) stop at
      # punctuation, as in bash, instead of treating a whole path as one word.
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

      # Home Manager has no fnm module yet.
      eval "$(fnm env --use-on-cd --shell zsh)"

      # Aliases and shell functions from ~/dotfiles (stowed to ~/.config/bash
      # on the other machines).
      export MY_CONF_DIR="$HOME/dotfiles" # initckan reads templates/ckan.ini from it
      for _f in "$HOME/dotfiles/bash/.config/bash/"*.sh(N); do
        [[ -r "$_f" ]] && source "$_f"
      done
      unset _f
    '';
  };
}
