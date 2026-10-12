{ ... }: {
  flake.nixosModules.gaming = { ... }: {
    # The module also turns on 32-bit graphics drivers, which most games need.
    programs.steam.enable = true;

    # Opt-in per game: set the Steam launch options to `gamemoderun %command%`.
    programs.gamemode.enable = true;
  };
}
