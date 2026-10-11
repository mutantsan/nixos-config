{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./_hardware-configuration.nix
      inputs.noctalia-greeter.nixosModules.default
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.kiwi = import ./_home.nix;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Kyiv";

  # Select internationalisation properties.
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

  # Login screen: Noctalia Greeter on greetd.
  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "hyprland";
      user.default = "kiwi";
      appearance = {
        scheme = "Nord";
        theme_mode = "dark";
      };
      keyboard.layout = "us";
    };
  };
  services.displayManager.defaultSession = "hyprland";

  # Firmware updates (fwupdmgr).
  services.fwupd.enable = true;

  # Secret service for the Hyprland session, unlocked at login.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."kiwi" = {
    isNormalUser = true;
    description = "kiwi";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    ];
  };

  virtualisation.docker.enable = true;

  # Dev services. Units run with --rm, so anything worth keeping needs a
  # volume. Ports bind to localhost because Docker bypasses the firewall.
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      pg18 = {
        image = "pgvector/pgvector:pg18";
        ports = [ "127.0.0.1:5432:5432" ];
        environment = {
          POSTGRES_USER = "root";
          POSTGRES_PASSWORD = "root";
        };
        volumes = [ "pg18-data:/var/lib/postgresql" ];
      };
      smtp4dev = {
        image = "rnwood/smtp4dev";
        ports = [ "127.0.0.1:1025:25" "127.0.0.1:5001:80" ];
      };
      redis8 = {
        image = "redis:8";
        ports = [ "127.0.0.1:6379:6379" ];
        volumes = [ "redis8-data:/data" ];
      };
      solr9 = {
        image = "solr:9";
        ports = [ "127.0.0.1:8983:8983" ];
        volumes = [ "solr9-data:/var/solr" ];
      };
    };
  };

  programs.zsh.enable = true;

  # Loader for prebuilt generic-Linux binaries, such as the Pythons that
  # `uv python install` downloads.
  programs.nix-ld.enable = true;
  # Extra libraries those binaries dlopen at runtime.
  programs.nix-ld.libraries = with pkgs; [
    file # libmagic, for python-magic
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
    ripgrep
    fd
    zip
    unzip
    btop
    tree
    file
    which

    claude-code
    chromium
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
