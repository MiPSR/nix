{ self, ... }: {
  flake.nixosModules.feature-caddy = { ... }: {
    containers.caddy = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "br-services";
      localAddress = "192.168.143.101/24";

      config = { pkgs, ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;

        nix.enable = false;

        networking.defaultGateway = "192.168.143.254";

        services.caddy = {
          enable = true;
          openFirewall = false;

          configFile = pkgs.writeText "Caddyfile" ''
            http://192.168.143.101:80 {
              respond ":)"
            }
          '';
        };
      };
    };

    systemd.services."container@caddy" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}
