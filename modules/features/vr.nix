{ self, ... }: {
  flake.nixosModules.feature-vr = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      alcom
      bs-manager
      wayvr
      wivrn
    ];

    networking.firewall = {
      allowedTCPPorts = [ 9757 ];
      allowedUDPPorts = [ 9757 ];
    };

    services.avahi.enable = true;
  };
}
