{ ... }: {
  flake.nixosModules.feature-wifi-miyu-mini = { lib, pkgs, ... }: {
    networking.networkmanager.ensureProfiles.profiles.miyu-ap = {
      connection = {
        id = "miyu-ap";
        uuid = "1a2b3c4d-0000-4000-8000-000000000012";
        type = "wifi";
        interface-name = "wlp0s20f0u6";
        master = "1a2b3c4d-0000-4000-8000-000000000002";
        autoconnect = true;
      };
      bridge-port = {
        path-cost = 100;
      };
      wifi = {
        mode = "ap";
        ssid = "미유";
        band = "bg";
        channel = 6;
      };
      wifi-security = {
        key-mgmt = "sae";
        psk = lib.strings.removeSuffix "\n" (builtins.readFile ../../secrets/wifi-miyu-psk);
        proto = "rsn;";
        pairwise = "ccmp;";
        group = "ccmp;";
      };
      ipv4.method = "disabled";
      ipv6.method = "disabled";
    };

    containers.wifi-kea = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_wifi_100";
      localAddress = "192.168.100.100/24";

      config = { ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;
        nix.enable = false;

        networking.defaultGateway = "192.168.100.254";
        networking.nameservers = [
          "1.1.1.1"
          "1.0.0.1"
        ];

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
                subnet = "192.168.100.0/24";
                interface = "eth0";
                pools = [
                  {
                    pool = "192.168.100.1 - 192.168.100.99";
                  }
                ];
                option-data = [
                  {
                    name = "routers";
                    data = "192.168.100.254";
                  }
                  {
                    name = "domain-name-servers";
                    data = "192.168.200.100";
                  }
                  {
                    name = "domain-name";
                    data = "lan";
                  }
                  {
                    name = "broadcast-address";
                    data = "192.168.100.255";
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

    containers.blocky-wifi = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_wifi_200";
      localAddress = "192.168.200.100/24";

      config = { ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;

        nix.enable = false;

        networking.defaultGateway = "192.168.200.254";
        networking.nameservers = [
          "1.1.1.1"
          "1.0.0.1"
        ];

        networking.firewall.allowedTCPPorts = [
          53
          4000
        ];
        networking.firewall.allowedUDPPorts = [ 53 ];

        services.blocky = {
          enable = true;

          settings = {
            ports.dns = "192.168.200.100:53";
            ports.http = "192.168.200.100:4000";

            upstreams = {
              groups.default = [
                "tcp-tls:cloudflare-dns.com"
                "https://cloudflare-dns.com/dns-query"
              ];
              strategy = "parallel_best";
            };

            bootstrapDns = [
              "tcp+udp:1.1.1.1"
              "tcp+udp:1.0.0.1"
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

              clientGroupsBlock.default = [ "blocklistproject" ];

              loading.refreshPeriod = "24h";
            };
          };
        };
      };
    };

    networking.nat = {
      enable = true;
      internalIPs = [
        "192.168.100.0/24"
        "192.168.200.0/24"
      ];
      internalInterfaces = [
        "bridge_wifi_100"
        "bridge_wifi_200"
      ];
    };

    networking.firewall.extraForwardRules = ''
      ip saddr 192.168.100.0/24 ip daddr 192.168.244.101 tcp dport 80 accept

      ip saddr 192.168.100.0/24 ip daddr 192.168.200.100 udp dport 53 accept
      ip saddr 192.168.100.0/24 ip daddr 192.168.200.100 tcp dport 53 accept

      ip saddr 192.168.100.0/24 ip daddr 192.168.200.100 tcp dport 4000 accept
      ip saddr 192.168.100.0/24 ip daddr 192.168.244.100 tcp dport 4000 accept
    '';

    networking.nftables.tables.wifi-miyu-containment = {
      family = "inet";
      content = ''
        chain forward {
          type filter hook forward priority -10; policy accept;

          ip saddr 192.168.100.0/24 ip daddr {
            10.0.0.0/8,
            172.16.0.0/12,
            192.168.144.0/24
          } reject
        }
      '';
    };

    networking.firewall.extraInputRules = ''
      iifname "bridge_wifi_100" ct state established,related accept
      iifname "bridge_wifi_100" counter drop comment "no host access from wifi"

      iifname "bridge_wifi_200" ct state established,related accept
      iifname "bridge_wifi_200" counter drop comment "no host access from wifi dns"
    '';

    systemd.services.wifi-bridge-four-address = {
      description = "Enable four-address mode on the WiFi access point";
      wantedBy = [ "multi-user.target" ];
      after = [ "sys-subsystem-net-devices-wlp0s20f0u6.device" ];
      wants = [ "sys-subsystem-net-devices-wlp0s20f0u6.device" ];
      bindsTo = [ "sys-subsystem-net-devices-wlp0s20f0u6.device" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "-${pkgs.iw}/bin/iw dev wlp0s20f0u6 set 4addr on";
      };
    };

    systemd.services."container@blocky-wifi" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };

    systemd.services."container@wifi-kea" = {
      after = [
        "NetworkManager-ensure-profiles.service"
        "network-online.target"
        "sys-subsystem-net-devices-wlp0s20f0u6.device"
      ];
      wants = [
        "NetworkManager-ensure-profiles.service"
        "network-online.target"
        "sys-subsystem-net-devices-wlp0s20f0u6.device"
      ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}
