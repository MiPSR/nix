{ ... }: {
  flake.nixosModules.feature-homeassistant = { ... }: {
    containers.homeassistant = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_wifi_100";
      localAddress = "192.168.100.110/24";

      bindMounts."/var/lib/hass" = {
        hostPath = "/var/lib/hass";
        isReadOnly = false;
      };

      config = { ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;

        nix.enable = false;

        networking.defaultGateway = "192.168.100.254";
        networking.nameservers = [ "192.168.200.100" ];

        networking.firewall.allowedTCPPorts = [ 8123 ];
        networking.firewall.allowedUDPPorts = [
          5353
          67
        ];

        systemd.tmpfiles.rules = [ "d /var/lib/hass 0750 hass hass -" ];

        services.home-assistant = {
          enable = true;

          extraComponents = [
            "tplink"
            "mobile_app"
            "zeroconf"
            "dhcp"
          ];

          config = {
            homeassistant = {
              name = "homura";
              unit_system = "metric";
            };
            frontend = { };
            config = { };
            mobile_app = { };
            zeroconf = { };
            dhcp = { };
          };
        };
      };
    };

    networking.firewall.extraForwardRules = ''
      ip saddr 192.168.244.101 ip daddr 192.168.100.110 tcp dport 8123 accept
    '';

    systemd.services."container@homeassistant" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}
