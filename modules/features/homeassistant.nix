{ ... }: {
  flake.nixosModules.feature-homeassistant = { ... }: {
    # Home Assistant for the Tapo lights. UI-only setup: onboard in the
    # frontend and add the built-in TP-Link integration there. Nothing
    # about the bulbs lives in this repo: no IPs, no MACs, no secrets.
    #
    # Same broadcast domain as the bulbs on purpose: Tapo discovery does
    # not cross subnets, so the container sits on bridge_wifi_100 next to
    # them. The bulbs stay plain DHCP clients.
    containers.homeassistant = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_wifi_100";
      localAddress = "192.168.100.110/24";

      # Config and state live on the host so they survive a rebuild of
      # the container. Same path on both sides.
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

        # Container-local firewall defaults to drop; only the frontend
        # port, reached through caddy from bridge_services.
        networking.firewall.allowedTCPPorts = [ 8123 ];

        systemd.tmpfiles.rules = [ "d /var/lib/hass 0750 hass hass -" ];

        services.home-assistant = {
          enable = true;

          # Deliberately not default_config: only the Tapo integration's
          # dependencies are packaged. tplink itself is UI-configured.
          extraComponents = [ "tplink" ];

          config = {
            homeassistant = {
              name = "homura";
              unit_system = "metric";
            };
            frontend = { };
            config = { };
          };
        };
      };
    };

    # Caddy terminates on bridge_services and routes to the HA container
    # on the wifi bridge. Narrow to that single path; bulb traffic stays
    # pure L2 on the bridge and never touches this chain.
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
