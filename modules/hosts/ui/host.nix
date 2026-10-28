{ self, inputs, ... }: {
  flake.nixosConfigurations.ui = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { networking.hostName = "ui"; system.stateVersion = "26.05"; }
      self.nixosModules.feature-amdgpu
      self.nixosModules.feature-osu-lazer
      self.nixosModules.feature-osu-stable
      self.nixosModules.feature-retro
      self.nixosModules.feature-steam
      self.nixosModules.feature-vr
      self.nixosModules.host-ui-hardware
      self.nixosModules.profile-pc
    ];
  };
}
