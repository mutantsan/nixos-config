{ inputs, ... }: {
  flake.nixosModules.home = { config, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit inputs; };
    # Home Manager takes the username and home directory from users.users.
    home-manager.users.${config.my.user} = import ./_home.nix;
  };
}
