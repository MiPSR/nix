{ self, inputs, ... }: {
  flake.nixosConfigurations.homura = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ({
        networking.hostName = "homura";
        system.stateVersion = "26.05";

        networking.networkmanager.ensureProfiles.profiles = {
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

          bridge_wifi_200 = {
            connection = {
              id = "bridge_wifi_200";
              uuid = "1a2b3c4d-0000-4000-8000-000000000005";
              type = "bridge";
              interface-name = "bridge_wifi_200";
              autoconnect = true;
            };
            bridge.stp = false;
            ipv4 = {
              method = "manual";
              addresses = "192.168.200.254/24";
            };
            ipv6.method = "disabled";
          };

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

        boot.kernel.sysctl."net.bridge.bridge-nf-call-iptables" = 0;

        services.dnsmasq.enable = false;

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
      self.nixosModules.feature-caddy
      self.nixosModules.feature-lan-miyu
      self.nixosModules.feature-minecraft-server
      self.nixosModules.feature-vaultwarden
      self.nixosModules.feature-wifi-miyu-mini
    ];
  };
}
