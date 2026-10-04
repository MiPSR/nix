{ self, ... }: {
  flake.nixosModules.feature-blocky = { ... }: {
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
              allowlists.blocklistproject = [
                # Equivalent to AdGuard's @@||nhentai.net^: the apex plus every
                # subdomain (i.nhentai.net, t.nhentai.net, ...). porn.txt
                # contains the apex, so without this allowlist it would block.
                "*.nhentai.net"
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

    systemd.services."container@blocky" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}