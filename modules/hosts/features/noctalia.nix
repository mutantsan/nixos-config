{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings =
        (builtins.fromJSON
          (builtins.readFile ./noctalia.json)).settings;
    };

    # noctalia-shell owns ~/.config/noctalia/settings.json once it exists and
    # never re-reads the nix-generated copy, so force it back in sync on every
    # launch instead of only seeding it once.
    packages.noctaliaSettingsJson = pkgs.writeText "noctalia-settings.json"
      (builtins.toJSON
        (builtins.fromJSON
          (builtins.readFile ./noctalia.json)).settings);
  };
}
