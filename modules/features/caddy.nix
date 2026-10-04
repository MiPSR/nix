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
        networking.nameservers = [ "192.168.143.100" ];

        # Container-local firewall defaults to drop; the host's br-services
        # allowed*Ports do not reach into this netns.
        networking.firewall.allowedTCPPorts = [ 80 ];

        services.caddy = {
          enable = true;
          openFirewall = false;

          # illegal.lan is the only site that has a real address; it is
          # rewritten to this container by blocky. The :80 catch-all keeps
          # something sane for direct-IP visits, so it has to come last.
          configFile = pkgs.writeText "Caddyfile" ''
            http://illegal.lan {
              respond "<!DOCTYPE html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>Blocked</title><style>html,body{height:100%;margin:0}body{background:#0b3d3a;display:flex;align-items:center;justify-content:center}h1{color:#fff;font:900 10vw/1.05 system-ui,-apple-system,Segoe UI,Roboto,sans-serif;text-align:center;max-width:92vw;text-shadow:-3px -3px 0 #000,3px -3px 0 #000,-3px 3px 0 #000,3px 3px 0 #000,0 0 28px #000,0 0 60px #000}</style></head><body><h1>This website is not allowed</h1></body></html>" 403
            }

            :80 {
              respond "<!DOCTYPE html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>Blocked</title><style>html,body{height:100%;margin:0}body{background:#0b3d3a;display:flex;align-items:center;justify-content:center}h1{color:#fff;font:900 26vw/1 system-ui,-apple-system,Segoe UI,Roboto,sans-serif;text-align:center;text-shadow:-4px -4px 0 #000,4px -4px 0 #000,-4px 4px 0 #000,4px 4px 0 #000,0 0 28px #000,0 0 60px #000}</style></head><body><h1>= :)</h1></body></html>" 403
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
