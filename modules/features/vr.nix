{ self, ... }: {
  flake.nixosModules.feature-vr = { pkgs, ... }: {
    boot.kernelModules = [ "uinput" ];

    environment.systemPackages = with pkgs; [
      alcom
      bs-manager
      wayvr
    ];

    # Ports and avahi publishing are opened/configured by the service itself
    services.wivrn = {
      enable = true;
      openFirewall = true;

      # CAP_SYS_NICE, for asynchronous reprojection
      highPriority = true;

      # Steam OpenXR discovery
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
        # hostname unset: WiVRn defaults to the system hostname
      };
    };
  };
}
