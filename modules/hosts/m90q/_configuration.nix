{ config, lib, pkgs, ... }:

{
  imports = [
    ./_hardware-configuration.nix
  ]
  # Gitignored, so it is absent on a fresh clone.
  ++ lib.optional (builtins.pathExists ./_private.nix) ./_private.nix;

  my.user = "kiwi";

  networking.hostName = "m90q";

  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  my.hyprland.monitorScale = 1.25;

  # The QK65 identifies as an Apple keyboard, so hid_apple would turn its top
  # row into media keys. Make plain presses send F1-F12.
  boot.extraModprobeConfig = "options hid_apple fnmode=2";

  # The NixOS and Home Manager releases this machine was first installed with.
  # Some modules use them to stay compatible with data already on disk, so
  # don't bump them when upgrading. The flake inputs choose the release.
  system.stateVersion = "26.05";
  home-manager.users.${config.my.user}.home.stateVersion = "25.11";
}
