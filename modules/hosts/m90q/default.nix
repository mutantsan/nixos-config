{ self, inputs, ... }:
{
  flake.nixosConfigurations.m90q = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      ./_configuration.nix
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.hyprland
    ];
  };
}
