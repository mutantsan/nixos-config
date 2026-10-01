{ config, pkgs, ... }:

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
      foot.desktop
    '';

    ".config/foot/foot.ini".text = ''
      [main]
      include=~/.local/state/omarchy/current/theme/foot.ini
      term=xterm-256color
      font=FiraCode Nerd Font:size=11
      pad=14x14
      initial-window-mode=windowed
      workers=0

      [scrollback]
      lines=10000
      multiplier=7.0

      [cursor]
      style=block
      blink=no

      [key-bindings]
      clipboard-copy=Control+Insert Control+Shift+c XF86Copy
      primary-paste=none
      clipboard-paste=Shift+Insert Control+Shift+v XF86Paste

      [text-bindings]
      # Send Shift+Return as CSI-u so TUIs can distinguish it from Return.
      \x1b[13;2u=Shift+Return
      # Send Alt+Shift+Return as CSI-u so tmux can match M-S-Enter.
      \x1b[13;4u=Mod1+Shift+Return
    '';
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
    TERMINAL = "foot";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh.enable = true;

  programs.zsh.shellAliases = {
    "ll" = ''eza -la'';

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
      ];
      userSettings = {
        # Editor: Behavior
        "editor.copyWithSyntaxHighlighting" = false;
        "diffEditor.ignoreTrimWhitespace" = false;
        "editor.emptySelectionClipboard" = true;
        "editor.snippetSuggestions" = "top";
        "editor.suggest.showSnippets" = true;
        "editor.detectIndentation" = false;
        "editor.tabSize" = 4;
        "editor.largeFileOptimizations" = false;
        "editor.hover.delay" = 300;
        "editor.inlayHints.enabled" = "offUnlessPressed";
        "editor.gotoLocation.multipleDefinitions" = "goto";
        "editor.gotoLocation.multipleImplementations" = "goto";
        "editor.gotoLocation.multipleReferences" = "goto";
        "editor.gotoLocation.multipleDeclarations" = "goto";
        "editor.gotoLocation.multipleTypeDefinitions" = "goto";

        # Editor: Appearance / hide unused UI
        "editor.minimap.enabled" = false;
        "editor.glyphMargin" = false;
        "editor.guides.indentation" = false;
        "editor.lineNumbers" = "off";
        "workbench.editor.showTabs" = "none";
        "breadcrumbs.enabled" = false;
        "workbench.tree.renderIndentGuides" = "none";
        "editor.matchBrackets" = "never";
        "editor.colorDecorators" = false;
        "editor.lightbulb.enabled" = "onCode";
        "editor.selectionHighlight" = false;
        "editor.overviewRulerBorder" = false;
        "editor.renderLineHighlight" = "none";
        "editor.occurrencesHighlight" = "off";
        "editor.renderControlCharacters" = false;
        "editor.hideCursorInOverviewRuler" = true;
        "workbench.editor.enablePreview" = false;
        "workbench.editor.enablePreviewFromQuickOpen" = false;
        "workbench.tips.enabled" = false;
        "workbench.tree.indent" = 16;

        # Editor: Font / cursor
        "editor.unicodeHighlight.ambiguousCharacters" = true;
        "editor.cursorBlinking" = "solid";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 13;
        "editor.lineHeight" = 1.6;
        "editor.fontFamily" = "MonoLisa, monospace";

        # Files
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;
        "files.exclude" = {
          "**/.git" = true;
          "**/.svn" = true;
          "**/.hg" = true;
          "**/CVS" = true;
          "**/.DS_Store" = true;
          "**/Thumbs.db" = true;
          "**/*.pyc" = true;
          "**/__pycache__" = true;
          "**/*.egg-info" = true;
          "**/.direnv/" = true;
          "**/.ruff_cache" = true;
          "**/.pytest_cache" = true;
          "**/node_modules/" = true;
        };
        "files.watcherExclude" = {
          "**/node_modules/**" = true;
          "**/__pycache__/**" = true;
          "**/venv/**" = true;
        };
        "files.associations" = {
          "*.html" = "html";
          "*.twig" = "html";
          "*.module" = "php";
        };

        # Explorer
        "explorer.compactFolders" = false;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "explorer.excludeGitIgnore" = true;

        # Search
        "search.useIgnoreFiles" = false;
        "search.exclude" = {
          "**/*.po" = true;
          "**/*.pot" = true;
          "**/example_*/" = true;
          "**/*.js.map" = true;
          "public/base" = true;
          "**/storage/webassets/" = true;
          "**/ckanext-*/site/" = true;
          "**/node_modules/" = true;
          "**/dist/" = true;
          "**/venv/" = true;
          "**/.venv/" = true;
        };

        # Git / SCM
        "git.decorations.enabled" = true;
        "git.openRepositoryInParentFolders" = "never";
        "scm.diffDecorations" = "all";
        "problems.decorations.enabled" = true;

        # Terminal
        "terminal.integrated.fontSize" = 14;
        "terminal.integrated.lineHeight" = 1.5;

        # Window
        "window.zoomLevel" = 3;
        "window.title" = "\${dirty}\${activeEditorMedium}\${separator}\${rootNameShort}";
        "window.newWindowDimensions" = "inherit";
        "window.controlsStyle" = "hidden";
        "window.commandCenter" = false;
        "window.menuBarVisibility" = "compact";

        # Workbench
        "workbench.colorTheme" = "Ocean Green: Dark";
        "workbench.experimental.modernUI" = false;
        "workbench.startupEditor" = "none";
        "workbench.sideBar.location" = "right";
        "workbench.activityBar.location" = "hidden";
        "workbench.navigationControl.enabled" = false;
        "workbench.browser.showInTitleBar" = false;
        "workbench.layoutControl.enabled" = false;
        "workbench.editorActionsLocation" = "hidden";
        "workbench.editorLargeFileConfirmation" = 25;
        "workbench.editorAssociations" = {
          "*.copilotmd" = "vscode.markdown.preview.editor";
          "{git,gitlens,chat-editing-snapshot-text-model,copilot,git-graph,git-graph-3}:/**/*.qrc" = "default";
          "{git,gitlens,chat-editing-snapshot-text-model,copilot,git-graph,git-graph-3}:/**/*.ui" = "default";
          "*.qrc" = "qt-core.qrcEditor";
        };

        # Remote
        "remote.autoForwardPortsSource" = "hybrid";

        # Chat / Copilot
        "chat.titleBar.openInAgentsWindow.enabled" = false;
        "chat.viewSessions.orientation" = "stacked";
        "chat.titleBar.signIn.enabled" = false;
        "chat.disableAIFeatures" = true;

        # Python
        "python.analysis.logLevel" = "Information";
        "python.analysis.autoImportCompletions" = true;
        "python.analysis.typeCheckingMode" = "standard";
        "python.analysis.indexing" = false;
        "python.analysis.extraPaths" = [
          "./ckan"
          "./../ckan"
          "./ckanext-blocksmith"
          "./ckanext-mailcraft"
          "./ckanext-admin-panel"
          "./ckanext-harvest"
          "./ckanext-harvest-basket"
          "./ckanext-dcat"
          "./ckanext-spatial"
          "./ckanext-scheming"
          "./ckanext-xloader"
          "./ckanext-toolbelt"
          "./ckanext-doi"
          "./ckanext-resource-docs"
          "./ckanext-cdp-iar"
          "./ckanext-dataset-series"
          "./ckanext-drupal-idp"
          "./ckanext-drupal-api"
          "./ckanext-tables"
          "./ckanext-transmute"
          "./ckanext-syndicate"
          "./ckanext-files"
          "./ckanext-better-stats"
          "./ckanext-event-audit"
          "./ckanext-knowledge-assistant"
          "./ckanext-theming"
          "./ckanext-portal-core"
          "./ckanext-portal-activity"
          "./ckanext-portal-revision"
          "./ckanext-bulk"
          "./ckanext-ingest"
          "./ckanext-search-autocomplete"
          "./ckanext-unfold"
        ];
        "ruff.configuration" = "/home/cherry/projects/pyproject.toml";

        # Language-specific formatters
        "[html]"."editor.defaultFormatter" = "vscode.html-language-features";
        "[rust]"."editor.defaultFormatter" = "rust-lang.rust-analyzer";
        "[json]"."editor.defaultFormatter" = "vscode.json-language-features";
        "[javascript]"."editor.defaultFormatter" = "vscode.typescript-language-features";
        "[javascriptreact]"."editor.defaultFormatter" = "vscode.typescript-language-features";
        "[less]"."editor.defaultFormatter" = "vscode.css-language-features";
        "[python]"."editor.defaultFormatter" = "charliermarsh.ruff";
        "[scss]"."editor.defaultFormatter" = "vscode.css-language-features";
        "[css]"."editor.defaultFormatter" = "vscode.css-language-features";
        "[yml]" = {
          "editor.formatOnSave" = false;
          "editor.autoIndent" = "advanced";
        };
      };

      keybindings = [
        # Text Editing
        { key = "ctrl+alt+backspace"; command = "deleteWordPartLeft"; }

        # Search
        { key = "alt+f"; command = "workbench.action.quickTextSearch"; }

        # Toggles
        {
          key = "alt+k alt+k";
          command = "toggle";
          when = "editorTextFocus";
          args = {
            id = "fontSize";
            value = [
              { "editor.fontSize" = 13; "editor.lineHeight" = 1.6; }
              { "editor.fontSize" = 10; "editor.lineHeight" = 1; }
            ];
          };
        }

        # File Explorer
        { key = "alt+n"; command = "explorer.newFile"; when = "explorerViewletVisible && filesExplorerFocus && !inputFocus"; }
        { key = "alt+shift+n"; command = "explorer.newFolder"; when = "explorerViewletVisible && filesExplorerFocus && !inputFocus"; }
        { key = "alt+r"; command = "workbench.files.action.refreshFilesExplorer"; when = "explorerViewletVisible && filesExplorerFocus && !inputFocus"; }

        # Fold & Unfold
        { key = "shift+alt+["; command = "editor.fold"; when = "editorFocus"; }
        { key = "shift+alt+]"; command = "editor.unfold"; when = "editorFocus"; }

        # Split Panels
        { key = "shift+alt+-"; command = "workbench.action.joinAllGroups"; when = "editorFocus"; }
        { key = "shift+alt+="; command = "workbench.action.splitEditor"; when = "editorFocus"; }
        { key = "shift+alt+right"; command = "workbench.action.navigateRight"; when = "editorFocus"; }
        { key = "shift+alt+left"; command = "workbench.action.navigateLeft"; when = "editorFocus"; }

        # Formatting
        { key = "ctrl+shift+i"; command = "editor.action.formatDocument"; }

        # Open DevTools
        { key = "alt+ctrl+i"; command = "workbench.action.toggleDevTools"; }

        # Hide Toaster Notifications
        { key = "escape"; command = "notifications.hideToasts"; when = "notificationToastsVisible"; }

        # View / Panel Navigation
        { key = "shift+ctrl+g"; command = "workbench.view.scm"; }
        { key = "shift+ctrl+e"; command = "workbench.view.explorer"; }
        { key = "ctrl+shift+d"; command = "dockerContainers.focus"; }
        { key = "ctrl+shift+b"; command = "workbench.view.debug"; }
        { key = "ctrl+shift+x"; command = "workbench.view.extensions"; }
        { key = "ctrl+shift+p"; command = "workbench.action.showCommands"; }
      ];
    };
  };

  programs.git = {
    enable = true;

    settings.user.name = "Oleksandr Cherniavskyi";
    settings.user.email = "kvaqich@gmail.com";
};

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # No home-manager module for fnm exists yet; hook it manually.
  programs.zsh.initContent = ''
    eval "$(fnm env --use-on-cd --shell zsh)"
  '';
}
