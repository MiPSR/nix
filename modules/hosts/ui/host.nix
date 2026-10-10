{ self, inputs, ... }: {
  flake.nixosConfigurations.ui = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { networking.hostName = "ui"; system.stateVersion = "26.05"; }
      self.nixosModules.feature-amdgpu
      self.nixosModules.feature-cinnamon
      self.nixosModules.feature-games
      self.nixosModules.feature-retro
      self.nixosModules.feature-vr
      self.nixosModules.feature-mate
      self.nixosModules.host-ui-hardware
      self.nixosModules.profile-pc
      ({ ... }: {
        services.pipewire.extraConfig.pipewire."50-clock" = {
          "context.properties" = {
            "clock.power-of-two-quantum" = false;
            "default.clock.allowed-rates" = [
              192000
              44100
            ];
            "default.clock.min-quantum" = 256;
            "default.clock.quantum" = 256;
            "default.clock.rate" = 192000;
          };
        };
      })
    ];
  };
}
