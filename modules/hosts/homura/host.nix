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

        networking.firewall.extraForwardRules = ''
          ip saddr 192.168.144.0/24 ip daddr 192.168.143.0/24 accept
          ip saddr 192.168.143.0/24 ip daddr 192.168.144.0/24 accept
          oifname "br-services" ct state new,established,related accept
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
          internalInterfaces = [ "br-services" ];
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

        services.dnsmasq.enable = false;

        # homura itself resolves via plain Quad9 rather than the ISP resolver.
        # Clients are pointed at AdGuard (192.168.143.100) by Kea instead.
        networking.nameservers = [
          "9.9.9.9"
          "149.112.112.112"
        ];

        services.kea.dhcp4 = {
          enable = true;
          settings = {
            interfaces-config.interfaces = [ "enp2s0" ];
            lease-database = {
              name = "/var/lib/kea/dhcp4.leases";
              persist = true;
              type = "memfile";
            };
            valid-lifetime = 43200;
            renew-timer = 21600;
            rebind-timer = 37800;
            subnet4 = [
              {
                id = 1;
                subnet = "192.168.144.0/24";
                interface = "enp2s0";
                pools = [
                  {
                    pool = "192.168.144.1 - 192.168.144.99";
                  }
                ];
                option-data = [
                  {
                    name = "routers";
                    data = "192.168.144.254";
                  }
                  {
                    name = "domain-name-servers";
                    data = "192.168.143.100";
                  }
                  {
                    name = "domain-name";
                    data = "lan";
                  }
                  {
                    name = "broadcast-address";
                    data = "192.168.144.255";
                  }
                  {
                    name = "subnet-mask";
                    data = "255.255.255.0";
                  }
                ];
              }
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
