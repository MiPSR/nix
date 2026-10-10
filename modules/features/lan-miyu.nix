{ ... }: {
  flake.nixosModules.feature-lan-miyu = { ... }: {
    networking.networkmanager.ensureProfiles.profiles.lan-port = {
      connection = {
        id = "lan-port";
        uuid = "1a2b3c4d-0000-4000-8000-000000000011";
        type = "ethernet";
        interface-name = "enp2s0";
        master = "1a2b3c4d-0000-4000-8000-000000000001";
        autoconnect = true;
      };
      bridge-port = {
        path-cost = 100;
      };
      ipv4.method = "disabled";
      ipv6.method = "disabled";
    };

    containers.lan-kea = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_lan_144";
      localAddress = "192.168.144.100/24";

      config = { ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;
        nix.enable = false;

        networking.defaultGateway = "192.168.144.254";
        networking.nameservers = [ "192.168.244.100" ];

        networking.firewall.allowedUDPPorts = [ 67 ];

        services.kea.dhcp4 = {
          enable = true;
          settings = {
            interfaces-config.interfaces = [ "eth0" ];
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
                interface = "eth0";
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
                    data = "192.168.244.100";
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
      };
    };

    containers.blocky = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_services";
      localAddress = "192.168.244.100/24";

      config = { ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;

        nix.enable = false;

        networking.defaultGateway = "192.168.244.254";
        networking.nameservers = [
          "9.9.9.9"
          "149.112.112.112"
        ];

        networking.firewall.allowedTCPPorts = [
          53
          4000
        ];
        networking.firewall.allowedUDPPorts = [ 53 ];

        services.blocky = {
          enable = true;

          settings = {
            ports.dns = "192.168.244.100:53";
            ports.http = "192.168.244.100:4000";

            upstreams = {
              groups.default = [
                "tcp-tls:dns.quad9.net"
                "https://dns.quad9.net/dns-query"
              ];
              strategy = "parallel_best";
            };

            bootstrapDns = [
              "tcp+udp:9.9.9.9"
              "tcp+udp:149.112.112.112"
            ];

            blocking = {
              denylists.blocklistproject = [
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/ads.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/abuse.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/adobe.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/basic.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/crypto.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/drugs.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/facebook.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/fortnite.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/fraud.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/gambling.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/malware.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/phishing.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/piracy.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/porn.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/ransomware.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/redirect.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/scam.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/smart-tv.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/urlshortener.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/youtube.txt"
              ];

              allowlists.blocklistproject = [
                ''
                  *.nhentai.net
                ''
                ''
                  *.saucenao.com
                ''
              ];

              clientGroupsBlock.default = [ "blocklistproject" ];

              loading.refreshPeriod = "24h";
            };

            rateLimit = {
              enable = true;
              rate = 20;
            };

            customDNS.mapping."info.lan" = "192.168.244.101";
            customDNS.mapping."illegal.lan" = "192.168.244.101";

            customDNS.mapping."mabbox.bytel.fr" = "192.168.1.254";
          };
        };
      };
    };

    networking.nat = {
      enable = true;
      externalInterface = "enp3s0";
      internalIPs = [
        "192.168.144.0/24"
        "192.168.244.0/24"
      ];
      internalInterfaces = [
        "bridge_lan_144"
        "bridge_services"
      ];
      forwardPorts = [
        {
          sourcePort = 25565;
          destination = "192.168.244.110:25565";
        }
        {
          sourcePort = 25565;
          destination = "192.168.244.110:25565";
          proto = "udp";
        }
      ];
    };

    networking.firewall.extraForwardRules = ''
      ip saddr 192.168.144.0/24 ip daddr 192.168.244.0/24 accept
      ip saddr 192.168.244.0/24 ip daddr 192.168.144.0/24 accept
    '';

    networking.firewall.interfaces.bridge_lan_144 = {
      allowedTCPPorts = [ 22 ];
    };

    networking.firewall.interfaces.bridge_services = {
      allowedTCPPorts = [
        53
        80
        443
        4000
        25565
      ];
      allowedUDPPorts = [
        53
        25565
      ];
    };

    systemd.services."container@blocky" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };

    systemd.services."container@lan-kea" = {
      after = [
        "NetworkManager-ensure-profiles.service"
        "network-online.target"
      ];
      wants = [
        "NetworkManager-ensure-profiles.service"
        "network-online.target"
      ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}
