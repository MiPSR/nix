{ self, ... }: {
  flake.nixosModules.feature-adguard = { ... }: {
    containers.adguard = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "br-services";
      localAddress = "192.168.143.100/24";

      config = { ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;

        nix.enable = false;

        networking.defaultGateway = "192.168.143.254";
        # Plain Quad9 for the container's *own* resolution (upstream hostnames,
        # bootstrap). Pointing this at AdGuard itself would be a DNS loop.
        networking.nameservers = [
          "9.9.9.9"
          "149.112.112.112"
        ];

        # NixOS enables the container's own firewall by default, and it drops
        # everything but ICMP. The host's allowed*Ports on br-services only open
        # the host INPUT chain, they do not reach into this netns, so LAN
        # clients (and LAN -> services forwarding) have to be opened here.
        networking.firewall.allowedTCPPorts = [
          53
          3000
        ];
        networking.firewall.allowedUDPPorts = [ 53 ];

        services.adguardhome = {
          enable = true;
          mutableSettings = false;
          host = "192.168.143.100";
          port = 3000;

          settings = {
            dns = {
              bind_hosts = [ "192.168.143.100" ];
              port = 53;
              upstream_dns = [
                "tls://dns.quad9.net"
                "https://dns.quad9.net/dns-query"
              ];
              bootstrap_dns = [
                "9.9.9.9"
                "149.112.112.112"
              ];
              ratelimit = 20;
            };

            filtering = {
              filtering_enabled = true;
              # Blocked domains are dead-resolved (0.0.0.0 / ::), browsers never
              # reach them, so no block page can be shown over HTTPS.
              blocking_mode = "default";
              # Both flags default to false when absent from the YAML, which
              # makes AdGuard parse the rewrites below and then silently ignore
              # them. Only wizard-generated configs get the true default.
              rewrites_enabled = true;
              rewrites = [
                {
                  domain = "illegal.lan";
                  answer = "192.168.143.101";
                  enabled = true;
                }
              ];
            };

            filters = [
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/ads.txt";
                name = "blocklistproject-ads";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/abuse.txt";
                name = "blocklistproject-abuse";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/adobe.txt";
                name = "blocklistproject-adobe";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/basic.txt";
                name = "blocklistproject-basic";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/crypto.txt";
                name = "blocklistproject-crypto";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/drugs.txt";
                name = "blocklistproject-drugs";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/facebook.txt";
                name = "blocklistproject-facebook";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/fortnite.txt";
                name = "blocklistproject-fortnite";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/fraud.txt";
                name = "blocklistproject-fraud";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/gambling.txt";
                name = "blocklistproject-gambling";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/malware.txt";
                name = "blocklistproject-malware";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/phishing.txt";
                name = "blocklistproject-phishing";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/piracy.txt";
                name = "blocklistproject-piracy";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/porn.txt";
                name = "blocklistproject-porn";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/ransomware.txt";
                name = "blocklistproject-ransomware";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/redirect.txt";
                name = "blocklistproject-redirect";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/scam.txt";
                name = "blocklistproject-scam";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/smart-tv.txt";
                name = "blocklistproject-smart-tv";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/twitter.txt";
                name = "blocklistproject-twitter";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/urlshortener.txt";
                name = "blocklistproject-urlshortener";
                enabled = true;
              }
              {
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/main/youtube.txt";
                name = "blocklistproject-youtube";
                enabled = true;
              }
            ];

            filters_update_interval = "24h";

            user_rules = [
              "@@||nhentai.net^"
              "@@||i.nhentai.net^"
            ];
          };
        };
      };
    };

    systemd.services."container@adguard" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}
