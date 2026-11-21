{ self, ... }: {
  flake.nixosModules.feature-vr = { pkgs, ... }: {
    boot.kernelModules = [ "uinput" ];

    environment.systemPackages = with pkgs; [
      alcom
      bs-manager
      wayvr
    ];

    services.wivrn = {
      enable = true;
      openFirewall = true;

      highPriority = true;

      steam.importOXRRuntimes = true;
      steam.package = pkgs.steam;

      config.enable = true;
      config.json = {
        application = [ pkgs.wayvr ];
        encoder = {
          codec = "h265";
          encoder = "vaapi";
        };
        tcp-only = true;
      };
    };
  };
}
