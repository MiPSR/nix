{ self, ... }: {
  flake.nixosModules.profile-server = { pkgs, ... }: {
    boot.kernelPackages = pkgs.linuxPackages_hardened;

    imports = [
      self.nixosModules.feature-base
      self.nixosModules.feature-user-m
    ];
  };
}
