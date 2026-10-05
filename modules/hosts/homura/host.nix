{ self, inputs, ... }: {
  flake.nixosConfigurations.homura = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      # Nix needs the parens here: a bare lambda as the first list element
      # parses as an attrset.
      ({
        networking.hostName = "homura";
        system.stateVersion = "26.05";

        # homura holds the .254 address on every network it serves. The Kea
        # containers sit on the same bridges as their clients so DHCP
        # broadcasts reach them directly, which is why they do not need their
        # own routed subnet or a relay agent.
        #
        # The bridge UUIDs are referenced by the two features that own the
        # matching ports, so a change here has to be mirrored there.
        networking.networkmanager.ensureProfiles.profiles = {
          # 192.168.144.0/24 - wired LAN. enp2s0 is a bridge port, so the
          # address lives on the bridge and clients and the Kea container share
          # one broadcast domain.
          bridge_lan_144 = {
            connection = {
              id = "bridge_lan_144";
              uuid = "1a2b3c4d-0000-4000-8000-000000000001";
              type = "bridge";
              interface-name = "bridge_lan_144";
              autoconnect = true;
            };
            bridge.stp = false;
            ipv4 = {
              method = "manual";
              addresses = "192.168.144.254/24";
            };
            ipv6.method = "disabled";
          };

          # 192.168.100.0/24 - WiFi access point. wlp0s20f0u6 is a bridge port
          # and the WPA3 profile is defined in feature-wifi-miyu-mini.
          bridge_wifi_100 = {
            connection = {
              id = "bridge_wifi_100";
              uuid = "1a2b3c4d-0000-4000-8000-000000000002";
              type = "bridge";
              interface-name = "bridge_wifi_100";
              autoconnect = true;
            };
            bridge.stp = false;
            ipv4 = {
              method = "manual";
              addresses = "192.168.100.254/24";
            };
            ipv6.method = "disabled";
          };

          # 192.168.244.0/24 - container-only network. No physical port: blocky,
          # caddy and minecraft attach over veth. Reachable from the LAN but
          # never from the WiFi side.
          bridge_services = {
            connection = {
              id = "bridge_services";
              uuid = "1a2b3c4d-0000-4000-8000-000000000003";
              type = "bridge";
              interface-name = "bridge_services";
              autoconnect = true;
            };
            bridge.stp = false;
            ipv4 = {
              method = "manual";
              addresses = "192.168.244.254/24";
            };
            ipv6.method = "disabled";
          };

          # Physical WAN port, untouched by the bridges.
          homura-wan = {
            connection = {
              id = "homura-wan";
              uuid = "1a2b3c4d-0000-4000-8000-000000000004";
              type = "ethernet";
              interface-name = "enp3s0";
              autoconnect = true;
            };
            ipv4.method = "auto";
            ipv6.method = "disabled";
          };
        };

        networking.nftables.enable = true;
        networking.firewall.filterForward = true;

        # DHCP comes from the two kea containers, never from the dnsmasq that
        # NetworkManager would otherwise spawn for a shared-mode connection.
        services.dnsmasq.enable = false;

        # homura itself resolves via plain Quad9 rather than the ISP resolver.
        # LAN clients are pointed at blocky (192.168.244.100) by kea instead.
        networking.nameservers = [
          "9.9.9.9"
          "149.112.112.112"
        ];

        services.openssh = {
          enable = true;
          openFirewall = false;
        };
      })
      self.nixosModules.host-homura-hardware
      self.nixosModules.profile-server
      self.nixosModules.feature-lan-miyu
      self.nixosModules.feature-wifi-miyu-mini
      self.nixosModules.feature-minecraft-server
      self.nixosModules.feature-caddy
    ];
  };
}
