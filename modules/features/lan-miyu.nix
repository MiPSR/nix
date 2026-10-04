{ ... }: {
  # LAN half of the 미유 network.
  #
  # Owns everything on 192.168.143.0/24 (services) and 192.168.144.0/24 (LAN):
  # DNS (blocky), DHCP (kea), NAT routing and firewall. Kea runs in its own
  # container so a failure there cannot take out anything outside this feature.
  flake.nixosModules.feature-lan-miyu = { ... }: {
    containers.blocky = {
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
        # blocklist URLs, bootstrap). Pointing this at blocky itself would be a
        # DNS loop.
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
          4000
        ];
        networking.firewall.allowedUDPPorts = [ 53 ];

        services.blocky = {
          enable = true;

          settings = {
            # Only listen on the container address; a wildcard bind would also
            # answer on the loopback/bridge interfaces inside the netns.
            ports.dns = "192.168.143.100:53";
            ports.http = "192.168.143.100:4000";

            # Blocked domains are dead-resolved (0.0.0.0 / ::), browsers never
            # reach them, so no block page can be shown over HTTPS. blocky is
            # zeroIP by default, matching the old AdGuard blocking mode.
            upstreams = {
              groups.default = [
                "tcp-tls:dns.quad9.net"
                "https://dns.quad9.net/dns-query"
              ];
              strategy = "parallel_best";
            };

            # Same role as AdGuard's bootstrap_dns: resolve the blocklist URLs
            # without going through blocky itself.
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
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/twitter.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/urlshortener.txt"
                "https://raw.githubusercontent.com/blocklistproject/Lists/main/youtube.txt"
              ];

              # Keep this group non-empty on the denylist side: a client whose
              # groups are all allowlist-only flips into exclusive allow mode,
              # which would block the whole internet.
              #
              # Must be an indented ('') string, not a plain one: blocky types a
              # list entry as inline text only if it contains a newline,
              # otherwise it assumes http(s) URL or *local file path*. A plain
              # "*.nhentai.net" is read as a filename, fails, and silently
              # leaves the allowlist empty.
              allowlists.blocklistproject = [
                # Equivalent to AdGuard's @@||nhentai.net^: the apex plus every
                # subdomain (i.nhentai.net, t.nhentai.net, ...). porn.txt
                # contains the apex, so without this allowlist it would block.
                ''
                  *.nhentai.net
                ''
              ];

              # No client name/IP override, so every client gets this group.
              clientGroupsBlock.default = [ "blocklistproject" ];

              loading.refreshPeriod = "24h";
            };

            # AdGuard's ratelimit, same units (sustained queries/sec/client).
            rateLimit = {
              enable = true;
              rate = 20;
            };

            customDNS.mapping."illegal.lan" = "192.168.143.101";
          };
        };
      };
    };

    # Kea shares the host network namespace (privateNetwork defaults to false),
    # so it can bind enp2s0 directly and hand out leases to real LAN clients
    # without a bridge or a relay agent. Its firewall and nftables are both
    # disabled on purpose: in a shared netns either one would flush or fight the
    # host's own ruleset.
    containers.lan-kea = {
      autoStart = true;
      restartIfChanged = true;

      config = { ... }: {
        system.stateVersion = "26.05";

        nix.enable = false;

        networking.enableIPv6 = false;
        networking.firewall.enable = false;
        networking.nftables.enable = false;
        networking.useDHCP = false;
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
      };
    };

    networking.nat = {
      enable = true;
      externalInterface = "enp3s0";
      internalIPs = [
        "192.168.144.0/24"
        "192.168.143.0/24"
      ];
      internalInterfaces = [ "br-services" ];
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
        4000
        25565
      ];
      allowedUDPPorts = [
        53
        25565
      ];
    };

    # UDP 67 is the kea container answering on this link; it shares the host
    # netns, so the host INPUT chain is still what gates it. Everything except
    # DHCP and ICMP stays closed.
    networking.firewall.interfaces.enp2s0 = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 67 ];
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
