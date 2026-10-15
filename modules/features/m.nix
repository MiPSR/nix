{ self, ... }: {
  flake.nixosModules.feature-user-m = { pkgs, ... }: {
    imports = [ self.nixosModules.feature-brush ];

    users.users.m = {
      description = "Kévin";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      home = "/home/m";
      isNormalUser = true;
      shell = pkgs.brush;
    };
  };
}
