{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix # TODO: generate with `sudo nixos-generate-config` and drop in here
  ];

  # ── Boot ──────────────────────────────────────────────────────────────────
  # nixarchy requires UEFI + systemd-boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Identity ──────────────────────────────────────────────────────────────
  networking.hostName = "nixos"; # TODO: real hostname (also rename the flake output + home file)
  networking.networkmanager.enable = true;
  time.timeZone = "Australia/Sydney"; # TODO: confirm
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.cherry = {
    isNormalUser = true;
    description = "cherry";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "input" ];
    shell = pkgs.zsh;
  };
  # Enables zsh as a login shell + /etc/zshrc + completion. Does NOT write
  # ~/.zshrc — dotfiles' stow'd ~/.zshrc owns that (see home/cherry.nix).
  programs.zsh.enable = true;

  # ── Omarchy desktop (nixarchy) ────────────────────────────────────────────
  # Do NOT also set programs.hyprland.package — nixarchy asserts its own
  # Lua-API Hyprland build.
  programs.nixarchy = {
    enable = true;
    user = "cherry"; # the user who runs the desktop
    browserThemeUser = "cherry"; # theme switches also recolor Chromium/Brave/etc.
    # Path where `nixarchy-apply` writes app picks before a rebuild.
    # TODO: must be the real on-disk path of THIS repo on the new machine.
    flake = "/home/cherry/nixos-config";
    # displayManager = true;   # SDDM + branded Omarchy greeter (default)
    # bootSplash = "defer";    # defer | force | off
    # defaultAgent = "claude"; # claude|codex|opencode|crush|gemini|copilot|grok
  };

  # ── Services matching the Omarchy machine ─────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  virtualisation.docker.enable = true;

  # Fn-row -> media keys, ported from dotfiles/etc/keyd/default.conf
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        brightnessdown = "f1";
        brightnessup = "f2";
        scale = "f3";
        dashboard = "f4";
        kbdillumdown = "f5";
        kbdillumup = "f6";
        previoussong = "f7";
        playpause = "f8";
        nextsong = "f9";
        mute = "f10";
        volumedown = "f11";
        volumeup = "f12";
      };
    };
  };

  # power-profiles-daemon is the Omarchy default; do NOT also enable TLP.
  services.power-profiles-daemon.enable = true;

  # Fonts (JetBrains Mono Nerd, Noto, CJK, emoji) come from nixarchy's vendored
  # Omarchy tree + preinstalls. Add extra font packages here only if something's
  # missing after first boot.

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05"; # TODO: match the installer's version, then never change
}
