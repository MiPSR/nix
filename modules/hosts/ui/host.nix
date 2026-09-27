{ self, inputs, ... }: {
  flake.nixosConfigurations.ui = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.host-ui-configuration
      self.nixosModules.host-ui-hardware
      self.nixosModules.profile-pc
    ];
  };
}
