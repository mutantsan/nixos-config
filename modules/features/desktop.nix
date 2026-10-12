{ inputs, ... }: {
  flake.nixosModules.desktop = { config, lib, pkgs, ... }: {
    imports = [ inputs.noctalia-greeter.nixosModules.default ];

    # Login screen: Noctalia Greeter on greetd.
    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        # Matched against the desktop entry's Name=, not its file name.
        session.default = "Hyprland (uwsm-managed)";
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
    services.displayManager.defaultSession = "hyprland-uwsm";

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

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      noto-fonts # Noto Sans, the GTK interface font (gtk.font in _home.nix)
    ];

    # Qt theming, to match the GTK setup in _home.nix. Set here rather than in
    # Home Manager: its session variables only reach shells, not apps started
    # from Hyprland.
    qt = {
      enable = true;
      style = "adwaita-dark";
    };
    # Qt's built-in GTK3 platform theme (not in the qt.platformTheme enum):
    # takes icons, fonts and file dialogs from the GTK settings.
    environment.variables.QT_QPA_PLATFORMTHEME = "gtk3";

    # Screen recording; the module also adds the setcap wrapper needed for
    # promptless capture.
    programs.gpu-screen-recorder.enable = true;

    environment.systemPackages = with pkgs; [
      chromium
      file-roller # archive manager
      loupe # image viewer
      mcomix # comic reader; Papers can't decode WebP pages
      mpv
      papers # PDF viewer
      zenity # dialogs for apps
    ];

    # Default apps.
    xdg.mime.defaultApplications = lib.genAttrs [
      "video/mp4"
      "video/x-matroska"
      "video/webm"
      "video/quicktime"
      "video/x-msvideo"
      "video/mpeg"
      "video/ogg"
      "video/x-flv"
      "video/3gpp"
      "video/mp2t"
    ] (_: "mpv.desktop") // lib.genAttrs [
      "image/png"
      "image/jpeg"
      "image/gif"
      "image/webp"
      "image/avif"
      "image/heic"
      "image/jxl"
      "image/bmp"
      "image/tiff"
      "image/svg+xml"
    ] (_: "org.gnome.Loupe.desktop") // lib.genAttrs [
      "application/zip"
      "application/x-7z-compressed"
      "application/vnd.rar"
      "application/x-tar"
      "application/x-compressed-tar"
      "application/x-bzip-compressed-tar"
      "application/x-xz-compressed-tar"
      "application/x-zstd-compressed-tar"
      "application/gzip"
      "application/x-xz"
      "application/zstd"
    ] (_: "org.gnome.FileRoller.desktop") // lib.genAttrs [
      "application/vnd.comicbook+zip"
      "application/vnd.comicbook-rar"
      "application/x-cbz"
      "application/x-cbr"
      "application/x-cb7"
      "application/x-cbt"
    ] (_: "mcomix.desktop") // {
      "application/pdf" = "org.gnome.Papers.desktop";
    };
  };
}
