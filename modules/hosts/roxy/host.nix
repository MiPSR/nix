{ self, inputs, ... }: {
  flake.nixosConfigurations.roxy = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { networking.hostName = "roxy"; system.stateVersion = "26.05"; }
      self.nixosModules.feature-amdgpu
      self.nixosModules.feature-games
      self.nixosModules.feature-vr
      self.nixosModules.host-roxy-hardware
      self.nixosModules.profile-pc
    ];
  };
}
