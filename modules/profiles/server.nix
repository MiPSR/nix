{ self, ... }: {
  flake.nixosModules.profile-server = { pkgs, ... }: {
    boot.kernelPackages = pkgs.linuxPackages_latest;

    imports = [
      self.nixosModules.feature-base
      self.nixosModules.feature-user-m
    ];
  };
}
