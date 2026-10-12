{ self, inputs, ... }:
{
  flake.nixosConfigurations.m90q = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      ./_configuration.nix
      self.nixosModules.base
      self.nixosModules.desktop
      self.nixosModules.hyprland
      self.nixosModules.dev
      self.nixosModules.home
    ];
  };
}
