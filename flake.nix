{
  description = "Defines NixOS system configurations from machine files.";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
    }:
    let
      lib = nixpkgs.lib;

      featureNames = lib.attrNames (
        lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./modules)
      );

      resolveFeature =
        profile: name:
        let
          dir = ./modules + "/${name}";
          profileFile = dir + "/${profile}.nix";
          defaultFile = dir + "/default.nix";
        in
        if builtins.pathExists profileFile then
          profileFile
        else if builtins.pathExists defaultFile then
          defaultFile
        else
          throw "modules/${name}: neither ${profile}.nix nor default.nix found";

      resolvedModules = profile: map (resolveFeature profile) featureNames;

      profileModule = {
        options.profile = lib.mkOption {
          type = lib.types.str;
          description = "Profile label (server/laptop) used to resolve feature modules.";
        };
      };

      mkHost =
        hostName:
        let
          profile =
            (lib.evalModules {
              modules = [
                { _module.check = false; }
                profileModule
                ./hosts/${hostName}.nix
              ];
              specialArgs = {
                hostname = hostName;
                pkgs = nixpkgs.legacyPackages."x86_64-linux";
              };
            }).config.profile;
        in
        {
          name = hostName;
          value = lib.nixosSystem {
            system = "x86_64-linux";
            modules =
              resolvedModules profile
              ++ [
                profileModule
                ./hosts/${hostName}.nix
              ]
              ++ [
                home-manager.nixosModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = {
                    hostname = hostName;
                    profile = profile;
                  };
                }
              ];
            specialArgs = {
              hostname = hostName;
              profile = profile;
            };
          };
        };

      hosts = [
        (mkHost "roxy")
      ];
    in
    {
      nixosConfigurations = builtins.listToAttrs hosts;
    };
}
