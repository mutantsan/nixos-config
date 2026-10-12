{ config, pkgs, ... }:

{
  imports = [
    ./_hardware-configuration.nix
  ];

  my.user = "kiwi";

  networking.hostName = "m90q";

  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  my.hyprland.monitorScale = 1.25;

  # Fn-row -> media keys
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

  # The NixOS release this machine was first installed with. Do not change it
  # on upgrade; it does not control which nixpkgs version is used.
  system.stateVersion = "26.05";

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home-manager.users.${config.my.user}.home.stateVersion = "25.11";
}
