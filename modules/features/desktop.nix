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
    # Lets the shell push its palette, mode and wallpaper to the greeter
    # without a password prompt on every theme change.
    services.displayManager.noctalia-greeter.passwordless-sync-users = [ config.my.user ];
    services.displayManager.defaultSession = "hyprland-uwsm";

    # Secret service for the Hyprland session, unlocked at login.
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    services.printing.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Kill the biggest process before the system thrashes into swap; the
    # kernel OOM killer only acts once RAM and swap are both exhausted.
    services.earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
      enableNotifications = true;
    };
    # On by default but monitors no slices; don't run two OOM daemons.
    systemd.oomd.enable = false;

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      noto-fonts # Noto Sans, the GTK interface font (gtk.font in _home.nix)
    ];

    # Qt theming through qt5ct/qt6ct, which apply the palette Noctalia's qt
    # template writes; their config is in _home.nix. Set here rather than in
    # Home Manager: its session variables only reach shells, not apps started
    # from Hyprland.
    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };

    # Screen recording; the module also adds the setcap wrapper needed for
    # promptless capture.
    programs.gpu-screen-recorder.enable = true;

    environment.systemPackages = with pkgs; [
      firefox
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
    ] (_: "mcomix.desktop") // lib.genAttrs [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ] (_: "firefox.desktop") // {
      "application/pdf" = "org.gnome.Papers.desktop";
    };
  };
}
