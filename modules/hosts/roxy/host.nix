{ self, inputs, ... }: {
  flake.nixosConfigurations.roxy = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        networking.hostName = "roxy";
        networking.firewall.interfaces.enp4s0f4u1u4.allowedTCPPorts = [ 22 ];
        networking.interfaces.enp4s0f4u1u4.wakeOnLan = {
          enable = true;
          policy = [ "magic" ];
        };
        system.stateVersion = "26.05";
      }
      self.nixosModules.feature-amdgpu
      self.nixosModules.feature-laptop
      self.nixosModules.feature-osu-lazer
      self.nixosModules.feature-osu-stable
      self.nixosModules.feature-ssd
      self.nixosModules.feature-steam
      self.nixosModules.feature-user-kzk
      self.nixosModules.host-roxy-hardware
      self.nixosModules.profile-pc
    ];
  };
}
