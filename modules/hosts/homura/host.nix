{ self, inputs, ... }: {
  flake.nixosConfigurations.homura = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      # Nix needs the parens here: a bare lambda as the first list element
      # parses as an attrset.
      ({
        networking.hostName = "homura";
        system.stateVersion = "26.05";

        # Only the physical links live here. Addressing policy for the LAN and
        # the AP belongs to feature-lan-miyu / feature-wifi-miyu-mini.
        networking.networkmanager.ensureProfiles.profiles = {
          homura-lan = {
            connection = {
              id = "homura-lan";
              type = "ethernet";
              interface-name = "enp2s0";
              autoconnect = true;
            };
            ipv4 = {
              method = "manual";
              addresses = "192.168.144.254/24";
            };
            ipv6.method = "disabled";
          };
          homura-wan = {
            connection = {
              id = "homura-wan";
              type = "ethernet";
              interface-name = "enp3s0";
              autoconnect = true;
            };
            ipv4.method = "auto";
            ipv6.method = "disabled";
          };
          br-services = {
            connection = {
              id = "br-services";
              type = "bridge";
              interface-name = "br-services";
              autoconnect = true;
            };
            bridge.stp = false;
            ipv4 = {
              method = "manual";
              addresses = "192.168.143.254/24";
            };
            ipv6.method = "disabled";
          };
        };

        networking.nftables.enable = true;
        networking.firewall.filterForward = true;

        # DHCP comes from the two kea containers, never from the dnsmasq that
        # NetworkManager would otherwise spawn for a shared-mode connection.
        services.dnsmasq.enable = false;

        # homura itself resolves via plain Quad9 rather than the ISP resolver.
        # LAN clients are pointed at blocky (192.168.143.100) by kea instead.
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
