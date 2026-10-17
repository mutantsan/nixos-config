{ ... }: {
  flake.nixosModules.base = { config, pkgs, lib, ... }: {
    options.my.user = lib.mkOption {
      type = lib.types.str;
      description = "Login name of the machine's primary user.";
    };

    config = {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.settings.auto-optimise-store = true;

      programs.nh = {
        enable = true;
        flake = "/home/${config.my.user}/nixos-config";
        clean = {
          enable = true;
          dates = "weekly";
          extraArgs = "--keep-since 14d --keep 5";
        };
      };

      # Compressed swap in RAM, used before the disk swap partition.
      zramSwap.enable = true;

      networking.networkmanager.enable = true;

      time.timeZone = "Europe/Kyiv";

      i18n.defaultLocale = "en_GB.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "uk_UA.UTF-8";
        LC_IDENTIFICATION = "uk_UA.UTF-8";
        LC_MEASUREMENT = "uk_UA.UTF-8";
        LC_MONETARY = "uk_UA.UTF-8";
        LC_NAME = "uk_UA.UTF-8";
        LC_NUMERIC = "uk_UA.UTF-8";
        LC_PAPER = "uk_UA.UTF-8";
        LC_TELEPHONE = "uk_UA.UTF-8";
        LC_TIME = "uk_UA.UTF-8";
      };

      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      console.keyMap = "us";

      # Firmware updates (fwupdmgr).
      services.fwupd.enable = true;

      users.users.${config.my.user} = {
        isNormalUser = true;
        description = config.my.user;
        shell = pkgs.zsh;
        extraGroups = [ "networkmanager" "wheel" ];
      };

      programs.zsh.enable = true;

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        btop
        curl
        fd
        file
        git
        gnumake
        neovim
        ripgrep
        tree
        unzip
        wget
        which
        zip
      ];
    };
  };
}
