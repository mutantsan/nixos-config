{ config, pkgs, ... }:

{
  home.username = "kiwi";
  home.homeDirectory = "/home/kiwi";

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11";

  home.packages = [
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.fzf
    pkgs.zoxide
    pkgs.eza
    pkgs.bat
    pkgs.delta
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
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh.enable = true;

  programs.pyenv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      history_filter = [
        "^cd$"
        "^cd \\.\\.$"
        "^pwd$"

        "^ls$"
        "^ll$"
        "^tls$"

        "^ga$"
        "^ga \\.$"
        "^gc$"
        "^gco \\.$"
        "^gco [^ ]+$"
        "^gadd$"

        "^gs$"
        "^gl$"
        "^gp$"

        "^npm ci$"
        "^npm i$"
        "^npm run .+$"

        "^jb$"
      ];
      search_mode = "fuzzy";
      style = "full";
      theme.name = "everforest";
      search.filters = [ "global" "session" "workspace" "directory" ];
      sync.records = true;
      enter_accept = false;
    };
    themes.everforest = {
      theme.name = "everforest";
      colors = {
        AlertInfo = "#a7c080";
        AlertWarn = "#dbbc7f";
        AlertError = "#e67e80";
        Annotation = "#9da9a0";
        Base = "#d3c6aa";
        Guidance = "#7fbbb3";
        Important = "#e09d7f";
        Title = "#83c092";
      };
    };
  };

  programs.git = {
    enable = true;

    settings.user.name = "Oleksandr Cherniavskyi";
    settings.user.email = "kvaqich@gmail.com";
};
}
