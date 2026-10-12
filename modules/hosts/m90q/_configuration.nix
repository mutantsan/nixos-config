{ config, pkgs, inputs, ... }:

let
  jtsCore = pkgs.fetchurl {
    url = "https://repo1.maven.org/maven2/org/locationtech/jts/jts-core/1.19.0/jts-core-1.19.0.jar";
    hash = "sha256-27hkTPMkEj0GwnqpgvVwgR4QtMsfKu+JOwDeI30z78A=";
  };
in
{
  imports = [
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

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
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
      # The greeter can't read themes from the user's home; point it at the
      # package (it looks in <path>/share/icons).
      cursor = {
        theme = "breeze_cursors";
        size = 24;
        path = "${pkgs.kdePackages.breeze}";
      };
    };
  };
  services.displayManager.defaultSession = "hyprland";

  # Firmware updates (fwupdmgr).
  services.fwupd.enable = true;

  # Secret service for the Hyprland session, unlocked at login.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  users.users."kiwi" = {
    isNormalUser = true;
    description = "kiwi";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
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
        volumes = [
          "solr9-data:/var/solr"
          # JTS for the spatial field types (ckanext-spatial). The image only
          # ships it in the sql module, off the webapp classpath.
          "${jtsCore}:/opt/solr/server/solr-webapp/webapp/WEB-INF/lib/${jtsCore.name}:ro"
        ];
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

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts # Noto Sans, the GTK interface font (gtk.font in _home.nix)
  ];

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
    gnumake

    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    chromium
  ];

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
}
