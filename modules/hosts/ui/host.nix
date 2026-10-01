{ self, inputs, ... }: {
  flake.nixosConfigurations.ui = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { networking.hostName = "ui"; system.stateVersion = "26.05"; }
      self.nixosModules.feature-amdgpu
      self.nixosModules.feature-games
      self.nixosModules.feature-vr
      self.nixosModules.host-ui-hardware
      self.nixosModules.profile-pc
      self.nixosModules.profile-plasma
      #self.nixosModules.feature-umbriel-m
      self.nixosModules.feature-niri-m
    ];
  };
}
