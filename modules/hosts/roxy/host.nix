{ self, inputs, ... }: {
  flake.nixosConfigurations.roxy = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { networking.hostName = "roxy"; system.stateVersion = "26.05"; }
      self.nixosModules.feature-amdgpu
      self.nixosModules.feature-laptop
      self.nixosModules.feature-osu-lazer
      self.nixosModules.feature-osu-stable
      self.nixosModules.feature-ssd
      self.nixosModules.feature-steam
      self.nixosModules.host-roxy-hardware
      self.nixosModules.profile-pc
    ];
  };
}
