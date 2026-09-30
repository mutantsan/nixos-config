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

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-boot 'on'
          set -g @continuum-boot-options 'fullscreen'
        '';
      }
    ];
    extraConfig = ''
      # Prefix
      set -g prefix C-\\
      set -g prefix2 C-b
      bind -N "Send prefix" C-\\ send-prefix

      # Config and help
      bind -N "Reload configuration" q source-file ~/.config/tmux/tmux.conf \; display "Configuration reloaded"

      # Vi mode for copyq
      setw -g mode-keys vi
      bind -N "Begin selection" -T copy-mode-vi v send -X begin-selection
      bind -N "Copy selection" -T copy-mode-vi y send -X copy-selection-and-cancel

      bind -N "Split pane vertically" _ split-window -v -c "#{pane_current_path}"
      bind -N "Split pane horizontally" | split-window -h -c "#{pane_current_path}"
      bind -N "Kill pane" x kill-pane

      # Default split keys inherit the current pane's directory too
      bind -N "Split pane vertically" '"' split-window -v -c "#{pane_current_path}"
      bind -N "Split pane horizontally" % split-window -h -c "#{pane_current_path}"

      bind -N "Focus pane left" -n C-M-Left select-pane -L
      bind -N "Focus pane right" -n C-M-Right select-pane -R
      bind -N "Focus pane up" -n C-M-Up select-pane -U
      bind -N "Focus pane down" -n C-M-Down select-pane -D

      bind -N "Resize pane left" -n C-M-S-Left resize-pane -L 5
      bind -N "Resize pane down" -n C-M-S-Down resize-pane -D 5
      bind -N "Resize pane up" -n C-M-S-Up resize-pane -U 5
      bind -N "Resize pane right" -n C-M-S-Right resize-pane -R 5

      # Window navigation
      bind -N "Rename window" r command-prompt -I "#W" "rename-window -- '%%'"
      bind -N "Create window" c new-window -c "#{pane_current_path}"
      bind -N "Kill window" k kill-window

      bind -N "Switch to window 1" -n M-1 select-window -t 1
      bind -N "Switch to window 2" -n M-2 select-window -t 2
      bind -N "Switch to window 3" -n M-3 select-window -t 3
      bind -N "Switch to window 4" -n M-4 select-window -t 4
      bind -N "Switch to window 5" -n M-5 select-window -t 5
      bind -N "Switch to window 6" -n M-6 select-window -t 6
      bind -N "Switch to window 7" -n M-7 select-window -t 7
      bind -N "Switch to window 8" -n M-8 select-window -t 8
      bind -N "Switch to window 9" -n M-9 select-window -t 9

      bind -N "Previous window" -n M-Left select-window -t -1
      bind -N "Next window" -n M-Right select-window -t +1
      bind -N "Move window left" -n M-S-Left swap-window -t -1 \; select-window -t -1
      bind -N "Move window right" -n M-S-Right swap-window -t +1 \; select-window -t +1

      # Session controls
      bind -N "Rename session" R command-prompt -I "#S" "rename-session -- '%%'"
      bind -N "Create session" C new-session -c "#{pane_current_path}"
      bind -N "Kill session" K kill-session
      bind -N "Previous session" P switch-client -p
      bind -N "Next session" N switch-client -n

      bind -N "Previous session" -n M-Up switch-client -p
      bind -N "Next session" -n M-Down switch-client -n

      # General
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",*:RGB"
      set -g mouse on
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -g history-limit 50000
      set -g escape-time 0
      set -g focus-events on
      set -g set-clipboard on
      set -g allow-passthrough on
      setw -g aggressive-resize on
      set -g detach-on-destroy off
      set -g extended-keys on
      set -g extended-keys-format csi-u
      set -ag terminal-features "xterm-ghostty:extkeys"
      set -as terminal-features ",*:clipboard"
      set -as terminal-features ",*:hyperlinks"
      set -sg escape-time 10
      set -g display-time 2500
      set -g display-panes-time 2500

      # Status bar
      set -g status-position top
      set -g status-interval 15
      set -g status-left-length 30
      set -g status-right-length 50
      set -g window-status-separator ""
      set -gw automatic-rename on
      set -gw automatic-rename-format '#{b:pane_current_path}'
      set -g set-titles on
      set -g set-titles-string '#h:#W'

      # Theme
      set -g status-style "bg=default,fg=default"
      set -g status-left "#[fg=black,bg=blue,bold] #S #[bg=default] "
      set -g status-right "#[fg=blue]#{?pane_in_mode,COPY ,}#{?client_prefix,PREFIX ,}#{?window_zoomed_flag,ZOOM ,}#[fg=brightblack]#h "
      set -g window-status-format "#[fg=brightblack] #I:#W "
      set -g window-status-current-format "#[fg=blue,bold] #I:#W "
      set -g pane-border-style "fg=brightblack"
      set -g pane-active-border-style "fg=blue"
      set -g message-style "bg=default,fg=blue"
      set -g message-command-style "bg=default,fg=blue"
      set -g mode-style "bg=blue,fg=black"
      setw -g clock-mode-colour blue
    '';
  };

  programs.git = {
    enable = true;

    settings.user.name = "Oleksandr Cherniavskyi";
    settings.user.email = "kvaqich@gmail.com";
};
}
