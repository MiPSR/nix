{ self, ... }: {
  flake.nixosModules.host-ui-configuration = { ... }: {
    imports = [
      self.nixosModules.feature-amdgpu
      self.nixosModules.feature-games
      self.nixosModules.feature-vr
    ];

    networking.hostName = "ui";

    system.stateVersion = "26.05";
  };
}
