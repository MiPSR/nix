{
  description = "M's flake.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.ui = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./modules
        ./hosts/ui.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.m = import ./modules/m/home.nix;
        }
      ];
    };
  };
}
