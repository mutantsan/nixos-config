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
  home.username = "kiwi";
  home.homeDirectory = "/home/kiwi";

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11";

  home.packages = [
    pkgs.fzf
    pkgs.zoxide
    pkgs.eza
    pkgs.bat
    pkgs.delta
    pkgs.jq
    pkgs.rustup
    pkgs.uv
    pkgs.nodejs
    pkgs.fnm
    pkgs.telegram-desktop
    pkgs.tmux
    pkgs.gettext # envsubst, for initckan
    tempie
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

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

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/kiwi/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "ghostty";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh.enable = true;

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

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        ms-python.python
        ms-python.debugpy
        ms-python.vscode-python-envs
        waderyan.gitblame
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
};

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.zsh.initContent = ''
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
