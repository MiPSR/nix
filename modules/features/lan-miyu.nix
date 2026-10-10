{ ... }: {
  # LAN half of the 미유 network.
  #
  # Two networks live here:
  #   192.168.144.0/24  wired LAN - homura .254, kea container .100, clients .1-.99
  #   192.168.244.0/24  container services - homura .254, blocky .100
  #
  # The kea container is private (own network namespace, own address) but is
  # bridged onto the same wire as the clients, so DHCP broadcasts reach it with
  # no relay agent. That is the whole point: a kea server on a *routed* subnet
  # cannot hear DHCP at all.
  flake.nixosModules.feature-lan-miyu = { ... }: {
    # enp2s0 becomes a port of bridge_lan_144. Its address moves to the bridge,
    # so it must not keep one of its own.
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

        # Only DHCP in. The host's allowed*Ports on bridge_lan_144 cannot reach
        # into this namespace, so they have to be opened here.
        networking.firewall.allowedUDPPorts = [ 67 ];

        services.kea.dhcp4 = {
          enable = true;
          settings = {
            # eth0 is the container's veth end. Inside a private namespace the
            # physical port is invisible, so kea has to be told the veth name.
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
        # Plain Quad9 for the container's *own* resolution (upstream hostnames,
        # blocklist URLs, bootstrap). Pointing this at blocky itself would be a
        # DNS loop.
        networking.nameservers = [
          "9.9.9.9"
          "149.112.112.112"
        ];

        # NixOS enables the container's own firewall by default, and it drops
        # everything but ICMP. The host's allowed*Ports on bridge_services only
        # open the host INPUT chain, they do not reach into this netns, so LAN
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
            ports.dns = "192.168.244.100:53";
            ports.http = "192.168.244.100:4000";

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
                ''
                  *.saucenao.com
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

            # info.lan/illegal.lan/hass.lan land on the caddy container next door; this
            # resolver's own API/metrics answer here on 192.168.244.100:4000.
            customDNS.mapping."info.lan" = "192.168.244.101";
            customDNS.mapping."illegal.lan" = "192.168.244.101";
            customDNS.mapping."hass.lan" = "192.168.244.101";

            # The ISP box on the WAN link answers this name for its own admin
            # UI: any http/https request to 192.168.1.254 is 302'd to
            # https://mabbox.bytel.fr/. Quad9 and Cloudflare both NXDOMAIN it -
            # it only exists in the box's own resolver - so without a static
            # map here every LAN client stalls on that redirect.
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

    # LAN reaches the services bridge and back. The WiFi feature adds its own
    # rules; none of them overlap with these.
    networking.firewall.extraForwardRules = ''
      ip saddr 192.168.144.0/24 ip daddr 192.168.244.0/24 accept
      ip saddr 192.168.244.0/24 ip daddr 192.168.144.0/24 accept
    '';

    # An interfaces.<iface> entry with no ports drops everything on that link
    # except established/related, so SSH is the only thing the LAN can reach on
    # homura itself. DHCP is not listed: the kea container answers directly on
    # the bridge and never traverses the host's INPUT chain.
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
