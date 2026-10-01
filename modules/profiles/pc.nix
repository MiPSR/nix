{ self, ... }: {
  flake.nixosModules.profile-pc = { pkgs, ... }: {
    boot.kernelPackages = pkgs.linuxPackages_zen;

    imports = [
      self.nixosModules.feature-base
      self.nixosModules.feature-gui
      self.nixosModules.feature-user-m
    ];
  };
}
