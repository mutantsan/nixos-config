{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.nixarchy.homeManagerModules.nixarchy
  ];

  home.username = "cherry";
  home.homeDirectory = "/home/cherry";
  home.stateVersion = "25.05"; # TODO: match configuration.nix

  # ── Omarchy look & feel ───────────────────────────────────────────────────
  programs.nixarchy = {
    enable = true;
    defaultTheme = "nord"; # source machine's active theme; switch at runtime with `omarchy theme set`
    # neovim = "theme-only"; # theme-only | adopt | off
  };

  home.packages = with pkgs; [ stow ];

  # ── Portable dotfiles — stay a separate stow repo ─────────────────────────
  # NOT auto-cloned: clone it yourself first (SSH keys aren't available during
  # `nixos-rebuild`), then every rebuild re-stows it:
  #   git clone git@github.com:mutantsan/dotfiles.git ~/dotfiles
  #
  # `bash` is deliberately excluded: nixarchy owns ~/.bashrc (Omarchy shell
  # integration + no hardcoded /usr/share/omarchy paths). To get the bash
  # aliases/functions from dotfiles/bash/.config/bash/*.sh, stow just that
  # subtree by hand or source it from programs.bash.initExtra.
  # `vscode` is left out: that stow package has stray keybindings.json/settings.json
  # at its root that would land in $HOME. Stow it by hand if you want it.
  home.activation.stowDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "$HOME/dotfiles/.git" ]; then
      run ${pkgs.stow}/bin/stow --restow --no-folding \
        --dir "$HOME/dotfiles" --target "$HOME" \
        atuin bat lsd vim zsh
    else
      warnEcho "~/dotfiles not found — clone git@github.com:mutantsan/dotfiles.git then rebuild"
    fi
  '';

  # ── zsh ───────────────────────────────────────────────────────────────────
  # ~/.zshrc is the stow'd dotfiles one (cross-platform, oh-my-zsh based).
  # Home Manager does NOT manage it — enabling programs.zsh here would fight
  # stow for the symlink. That .zshrc expects oh-my-zsh + external plugins
  # installed the same way as on Arch:
  #   git clone https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh
  #   git clone https://github.com/Aloxaf/fzf-tab              ~/.oh-my-zsh/custom/plugins/fzf-tab
  #   git clone https://github.com/zsh-users/zsh-autosuggestions      ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  #   git clone https://github.com/zsh-users/zsh-syntax-highlighting  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  # (pyenv / nvm / atuin / oh-my-posh that .zshrc also expects: install via the
  # Omarchy menu or mise, matching reference/packages-explicit.txt.)
}
