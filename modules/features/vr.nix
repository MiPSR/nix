{ self, ... }: {
  flake.nixosModules.feature-vr = { pkgs, ... }: {
    boot.kernelModules = [ "uinput" ];

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

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      settings.publish = {
        "disable-publishing" = false;
        "disable-user-service-publishing" = false;
        "publish-addresses" = true;
      };
    };
  };
}
