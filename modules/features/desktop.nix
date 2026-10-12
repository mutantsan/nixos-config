{ inputs, ... }: {
  flake.nixosModules.desktop = { config, pkgs, ... }: {
    imports = [ inputs.noctalia-greeter.nixosModules.default ];

    # Login screen: Noctalia Greeter on greetd.
    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        session.default = "hyprland";
        user.default = config.my.user;
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

    # Secret service for the Hyprland session, unlocked at login.
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

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

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      noto-fonts # Noto Sans, the GTK interface font (gtk.font in _home.nix)
    ];

    environment.systemPackages = with pkgs; [
      chromium
    ];
  };
}
