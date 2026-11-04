{ self, inputs, ... }: {
  flake.nixosConfigurations.lana = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { networking.hostName = "lana"; system.stateVersion = "26.05"; }
      self.nixosModules.feature-amdgpu
      self.nixosModules.feature-osu-lazer
      self.nixosModules.feature-osu-stable
      self.nixosModules.feature-steam
      self.nixosModules.feature-vr
      self.nixosModules.host-lana-hardware
      self.nixosModules.profile-pc
    ];
  };
}
