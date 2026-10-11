{ self, inputs, ... }:
{
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./_configuration.nix
      inputs.home-manager.nixosModules.home-manager
      { home-manager.extraSpecialArgs = { inherit inputs; }; }
      self.nixosModules.hyprland
    ];
  };
}
