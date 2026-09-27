{ self, ... }: {
  flake.nixosModules.feature-user-m = { pkgs, ... }: {
    users.users.m = {
      description = "Kévin";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      home = "/home/m";
      isNormalUser = true;
      shell = pkgs.nushell;
    };
  };
}
