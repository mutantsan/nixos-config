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

  # The keyboard's top row sends media keys by default; remap it to F1-F12
  # (see _hypr/bindings/media.lua).
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

  # The NixOS and Home Manager releases this machine was first installed with.
  # Some modules use them to stay compatible with data already on disk, so
  # don't bump them when upgrading. The flake inputs choose the release.
  system.stateVersion = "26.05";
  home-manager.users.${config.my.user}.home.stateVersion = "25.11";
}
