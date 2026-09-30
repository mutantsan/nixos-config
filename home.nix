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

  programs.zsh.shellAliases = {
    "g" = ''git'';

    "ga" = ''git add'';
    "gaa" = ''git add --all'';
    "gapa" = ''git add --patch'';
    "gau" = ''git add --update'';
    "gav" = ''git add --verbose'';
    "gap" = ''git apply'';

    "gb" = ''git branch'';
    "gba" = ''git branch -a'';
    "gbd" = ''git branch -d'';
    "gbda" = ''git branch --no-color --merged | command grep -vE "^(\+|\*|\s*(master|develop|dev)\s*$)" | command xargs -n 1 git branch -d'';
    "gbD" = ''git branch -D'';
    "gbl" = ''git blame -b -w'';
    "gbnm" = ''git branch --no-merged'';
    "gbr" = ''git branch --remote'';
    "gbs" = ''git bisect'';
    "gbsb" = ''git bisect bad'';
    "gbsg" = ''git bisect good'';
    "gbsr" = ''git bisect reset'';
    "gbss" = ''git bisect start'';

    "gc" = ''git commit -v'';
    "gc!" = ''git commit -v --amend'';
    "gcn!" = ''git commit -v --no-edit --amend'';
    "gca" = ''git commit -v -a'';
    "gca!" = ''git commit -v -a --amend'';
    "gcan!" = ''git commit -v -a --no-edit --amend'';
    "gcans!" = ''git commit -v -a -s --no-edit --amend'';
    "gcam" = ''git commit -a -m'';
    "gcsm" = ''git commit -s -m'';
    "gcb" = ''git checkout -b'';
    "gcf" = ''git config --list'';
    "gcl" = ''git clone --recurse-submodules'';
    "gclean" = ''git clean -id'';
    "gpristine" = ''git reset --hard && git clean -dfx'';
    "gcm" = ''git checkout master'';
    "gcd" = ''git checkout develop'';
    "gcmsg" = ''git commit -m'';
    "gco" = ''git checkout'';
    "gcount" = ''git shortlog -sn'';
    "gcp" = ''git cherry-pick'';
    "gcpa" = ''git cherry-pick --abort'';
    "gcpc" = ''git cherry-pick --continue'';
    "gcs" = ''git commit -S'';

    "gd" = ''git diff'';
    "gdca" = ''git diff --cached'';
    "gdcw" = ''git diff --cached --word-diff'';
    "gdct" = ''git describe --tags $(git rev-list --tags --max-count=1)'';
    "gds" = ''git diff --staged'';
    "gdt" = ''git diff-tree --no-commit-id --name-only -r'';
    "gdw" = ''git diff --word-diff'';

    "gf" = ''git fetch'';
    "gfa" = ''git fetch --all --prune'';
    "gfo" = ''git fetch origin'';

    "gfg" = ''git ls-files | grep'';

    "gg" = ''git gui citool'';
    "gga" = ''git gui citool --amend'';

    "ggpur" = ''ggu'';
    "ggpull" = ''git pull origin "$(git_current_branch)"'';
    "ggpush" = ''git push origin "$(git_current_branch)"'';

    "ggsup" = ''git branch --set-upstream-to=origin/$(git_current_branch)'';
    "gpsup" = ''git push --set-upstream origin $(git_current_branch)'';

    "ghh" = ''git help'';

    "gignore" = ''git update-index --assume-unchanged'';
    "gignored" = ''git ls-files -v | grep "^[[:lower:]]"'';
    "git-svn-dcommit-push" = ''git svn dcommit && git push github master:svntrunk'';

    "gk" = ''\gitk --all --branches'';
    "gke" = ''\gitk --all $(git log -g --pretty=%h)'';

    "gl" = ''git pull'';
    "glg" = ''git log --stat'';
    "glgp" = ''git log --stat -p'';
    "glgg" = ''git log --graph'';
    "glgga" = ''git log --graph --decorate --all'';
    "glgm" = ''git log --graph --max-count=10'';
    "glo" = ''git log --oneline --decorate'';
    "glol" = ''git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' '';
    "glols" = ''git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --stat'';
    "glod" = ''git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' '';
    "glods" = ''git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short'';
    "glola" = ''git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all'';
    "glog" = ''git log --oneline --decorate --graph'';
    "gloga" = ''git log --oneline --decorate --graph --all'';
    "glp" = ''_git_log_prettily'';

    "gm" = ''git merge'';
    "gmom" = ''git merge origin/master'';
    "gmt" = ''git mergetool --no-prompt'';
    "gmtvim" = ''git mergetool --no-prompt --tool=vimdiff'';
    "gmum" = ''git merge upstream/master'';
    "gma" = ''git merge --abort'';

    "gp" = ''git push'';
    "gpd" = ''git push --dry-run'';
    "gpf" = ''git push --force-with-lease'';
    "gpf!" = ''git push --force'';
    "gpoat" = ''git push origin --all && git push origin --tags'';
    "gpu" = ''git push upstream'';
    "gpv" = ''git push -v'';

    "gr" = ''git remote'';
    "gra" = ''git remote add'';
    "grb" = ''git rebase'';
    "grba" = ''git rebase --abort'';
    "grbc" = ''git rebase --continue'';
    "grbd" = ''git rebase develop'';
    "grbi" = ''git rebase -i'';
    "grbm" = ''git rebase master'';
    "grbs" = ''git rebase --skip'';
    "grev" = ''git revert'';
    "grh" = ''git reset'';
    "grhh" = ''git reset --hard'';
    "groh" = ''git reset origin/$(git_current_branch) --hard'';
    "grm" = ''git rm'';
    "grmc" = ''git rm --cached'';
    "grmv" = ''git remote rename'';
    "grrm" = ''git remote remove'';
    "grs" = ''git restore'';
    "grset" = ''git remote set-url'';
    "grss" = ''git restore --source'';
    "grt" = ''cd "$(git rev-parse --show-toplevel || echo .)"'';
    "gru" = ''git reset --'';
    "grup" = ''git remote update'';
    "grv" = ''git remote -v'';

    "gsb" = ''git status -sb'';
    "gsd" = ''git svn dcommit'';
    "gsh" = ''git show'';
    "gsi" = ''git submodule init'';
    "gsps" = ''git show --pretty=short --show-signature'';
    "gsr" = ''git svn rebase'';
    "gss" = ''git status -s'';
    "gst" = ''git status'';

    "gsta" = ''git stash push'';
    "gstaa" = ''git stash apply'';
    "gstc" = ''git stash clear'';
    "gstd" = ''git stash drop'';
    "gstl" = ''git stash list'';
    "gstp" = ''git stash pop'';
    "gsts" = ''git stash show --text'';
    "gstall" = ''git stash --all'';
    "gsu" = ''git submodule update'';
    "gsw" = ''git switch'';
    "gswc" = ''git switch -c'';

    "gts" = ''git tag -s'';
    "gtv" = ''git tag | sort -V'';

    "gunignore" = ''git update-index --no-assume-unchanged'';
    "gunwip" = ''git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'';
    "gup" = ''git pull --rebase'';
    "gupv" = ''git pull --rebase -v'';
    "gupa" = ''git pull --rebase --autostash'';
    "gupav" = ''git pull --rebase --autostash -v'';
    "glum" = ''git pull upstream master'';

    "gwch" = ''git whatchanged -p --abbrev-commit --pretty=medium'';
    "gwip" = ''git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'';

    "gs" = ''git status'';
  };

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
