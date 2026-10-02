{ self, inputs, ... }: {
  flake.nixosConfigurations.homura = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        networking.hostName = "homura";
        system.stateVersion = "26.05";

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
        };

        networking.bridges.br-services.interfaces = [ ];

        networking.interfaces.br-services.ipv4.addresses = [
          {
            address = "192.168.143.254";
            prefixLength = 24;
          }
        ];

        networking.nftables.enable = true;
        networking.firewall.filterForward = true;
        networking.firewall.checkReversePath = false;

        networking.firewall.extraForwardRules = ''
          ip saddr 192.168.144.0/24 ip daddr 192.168.143.0/24 accept
          ip saddr 192.168.143.0/24 ip daddr 192.168.144.0/24 ct state established,related accept
        '';

        networking.firewall.interfaces.br-services = {
          allowedTCPPorts = [
            53
            80
            443
            3000
            25565
          ];
          allowedUDPPorts = [
            53
            25565
          ];
        };

        networking.nat = {
          enable = true;
          internalIPs = [
            "192.168.144.0/24"
            "192.168.143.0/24"
          ];
          internalInterfaces = [ "enp2s0" ];
          externalInterface = "enp3s0";
          forwardPorts = [
            {
              sourcePort = 25565;
              destination = "192.168.143.110:25565";
            }
            {
              sourcePort = 25565;
              destination = "192.168.143.110:25565";
              proto = "udp";
            }
          ];
        };

        systemd.services."NetworkManager-wait-online".wantedBy = [ "multi-user.target" ];

        systemd.services."container-adguard" = {
          after = [
            "network-online.target"
            "NetworkManager-wait-online.service"
          ];
          wants = [
            "network-online.target"
            "NetworkManager-wait-online.service"
          ];
        };

        systemd.services."container-minecraft" = {
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        };

        systemd.services."container-caddy" = {
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        };

        services.dnsmasq = {
          enable = true;
          resolveLocalQueries = false;
          settings = {
            port = 0;
            interface = [ "enp2s0" ];
            bind-interfaces = true;
            dhcp-authoritative = true;
            dhcp-range = [ "192.168.144.1,192.168.144.99,255.255.255.0,12h" ];
            dhcp-option = [
              "option:router,192.168.144.254"
              "option:dns-server,192.168.143.100"
            ];
          };
        };

        networking.firewall.interfaces.enp2s0 = {
          allowedTCPPorts = [ 22 ];
          allowedUDPPorts = [ 67 ];
        };

        services.openssh = {
          enable = true;
          openFirewall = false;
        };
      }
      self.nixosModules.host-homura-hardware
      self.nixosModules.profile-server
      self.nixosModules.feature-adguard
      self.nixosModules.feature-minecraft-server
      self.nixosModules.feature-caddy
    ];
  };
}
