{ ... }: {
  # WiFi half of the 미유 network.
  #
  #   192.168.100.0/24  wifi clients - homura .254, kea container .100, clients .1-.99
  #   192.168.200.0/24  wifi DNS     - homura .254, blocky-wifi container .100
  #
  # LAN and WiFi must not share a DNS server, so this half runs its own blocky
  # on 192.168.200.100 (Cloudflare DoT/DoH upstreams) while the LAN keeps the
  # Quad9 one on 192.168.244.100 behind bridge_services - a bridge the AP side
  # has no path to. AP clients get their resolver from DHCP and reach it by
  # routing through homura; 53 and 4000 are opened in the forward rules below.
  #
  # The kea container is private but bridged onto the same radio as the
  # clients, so DHCP broadcasts reach it with no relay agent.
  flake.nixosModules.feature-wifi-miyu-mini = { lib, pkgs, ... }: {
    # WPA3-only, no WPA2 fallback. NetworkManager derives pmf=required from
    # key-mgmt=sae, which SAE mandates anyway.
    #
    # The adapter is a port of bridge_wifi_100, so the address lives on the
    # bridge and this profile must not carry one. master matches the bridge
    # uuid declared in modules/hosts/homura/host.nix.
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
        # RTL8192EU (TL-WN823N) is a 2.4GHz-only part. AP mode for this chip
        # has been in-tree in rtl8xxxu since v6.5, so no out-of-tree driver.
        band = "bg";
        channel = 6;
      };
      wifi-security = {
        key-mgmt = "sae";
        # A trailing newline would silently become part of the PSK and break
        # every association attempt.
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
        # Plain Cloudflare for the container's *own* resolution. kea does not
        # resolve anything for clients; pointing this at blocky-wifi would be a
        # DNS loop on a box whose only job is answering DHCP.
        networking.nameservers = [
          "1.1.1.1"
          "1.0.0.1"
        ];

        # Only DHCP in from the radio.
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
                    # The WiFi half gets its own resolver, never the LAN blocky
                    # on 192.168.244.100. That separation is also what keeps the
                    # containment rule below cheap: these clients have no reason
                    # to reach 192.168.244.0/24, the dashboard on .101 being the
                    # one deliberate exception.
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

    # The WiFi half's resolver. A second blocky instance rather than the LAN
    # one on purpose: LAN and WiFi must not share a DNS server, so this lives
    # on its own bridge with its own upstreams (Cloudflare DoT + DoH, no Quad9
    # anywhere on the WiFi side) and its own copy of the denylist. The
    # allowlists are deliberately not copied - those exist on the LAN side only.
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
        # Plain Cloudflare for the container's *own* resolution (upstream
        # hostnames, blocklist URLs, bootstrap). Pointing this at blocky-wifi
        # itself would be a DNS loop.
        networking.nameservers = [
          "1.1.1.1"
          "1.0.0.1"
        ];

        # Only DNS and the resolver API. The container's own firewall defaults
        # to drop, and host-side rules only ever govern traffic addressed to
        # homura itself - packets arriving for this container go through the
        # forward chain instead - so the ports must be opened in here.
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

            # Cloudflare only, encrypted both ways: DoT and DoH. This half of
            # the network never talks to a resolver in the clear, unlike the
            # LAN's Quad9 pair.
            upstreams = {
              groups.default = [
                "tcp-tls:cloudflare-dns.com"
                "https://cloudflare-dns.com/dns-query"
              ];
              strategy = "parallel_best";
            };

            # Same role as AdGuard's bootstrap_dns: resolve the blocklist URLs
            # and the DoT/DoH hostnames without going through blocky-wifi.
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

              # No allowlists on this side: this group is deny-only, which is
              # the normal blocking mode. It still must be a non-empty *deny*
              # group - a client whose groups are all allowlist-only flips into
              # exclusive allow mode, which would block the whole internet.
              clientGroupsBlock.default = [ "blocklistproject" ];

              loading.refreshPeriod = "24h";
            };

            # hass.lan lands on the caddy container, same as info.lan does on
            # the LAN side, so WiFi phones reach the lights dashboard.
            customDNS.mapping."hass.lan" = "192.168.244.101";
          };
        };
      };
    };

    networking.nat = {
      enable = true;
      # blocky-wifi needs outbound itself: blocklists over HTTP and upstreams
      # over DoT/DoH. Without its subnet here the container cannot reach the
      # internet at all, and every query would time out.
      internalIPs = [
        "192.168.100.0/24"
        "192.168.200.0/24"
      ];
      internalInterfaces = [
        "bridge_wifi_100"
        "bridge_wifi_200"
      ];
    };

    # What the WiFi side may reach: the caddy page on bridge_services, its own
    # resolver, and the LAN resolver's API. Everything else falls through to the
    # forward chain's drop policy (and 192.168.144.0/24 to the containment table
    # below). Replies need no rule: they are ct established, which the forward
    # chain accepts before consulting these.
    networking.firewall.extraForwardRules = ''
      ip saddr 192.168.100.0/24 ip daddr 192.168.244.101 tcp dport 80 accept

      ip saddr 192.168.100.0/24 ip daddr 192.168.200.100 udp dport 53 accept
      ip saddr 192.168.100.0/24 ip daddr 192.168.200.100 tcp dport 53 accept

      ip saddr 192.168.100.0/24 ip daddr 192.168.200.100 tcp dport 4000 accept
      ip saddr 192.168.100.0/24 ip daddr 192.168.244.100 tcp dport 4000 accept
    '';

    # AP clients get the internet and nothing else.
    #
    # This lives in its own table at priority -10 rather than in
    # networking.firewall.extraForwardRules on purpose. extraForwardRules is a
    # concatenated string, so whether these rejects land before or after
    # feature-lan-miyu's `ip saddr 192.168.144.0/24 ... accept` depends on
    # module evaluation order, and getting it wrong silently re-opens the LAN
    # and the services bridge to the AP. A base chain at a lower priority is
    # evaluated first, always. 192.168.244.0/24 is deliberately absent so the
    # dashboard stays reachable, and so is 192.168.200.0/24 so DNS does - that
    # subnet is still limited to 53 and 4000 by the forward rules above, never
    # opened wholesale.
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

    # AP clients must not reach homura itself. DHCP is deliberately absent: the
    # kea container answers on the bridge and never traverses this chain.
    #
    # An interfaces.<iface> entry is required rather than optional here. With
    # no entry at all nixpkgs emits no rule for the interface, and the global
    # input chain still accepts established/related plus loopback, so a client
    # could open a connection to something homura is already listening on.
    networking.firewall.extraInputRules = ''
      iifname "bridge_wifi_100" ct state established,related accept
      iifname "bridge_wifi_100" counter drop comment "no host access from wifi"

      iifname "bridge_wifi_200" ct state established,related accept
      iifname "bridge_wifi_200" counter drop comment "no host access from wifi dns"
    '';

    # Bridging a WiFi access point only carries client traffic if the driver
    # can tag each frame with the client's own address (four-address mode).
    # NetworkManager turns this on for a bridged AP when the driver advertises
    # support; this is the fallback for drivers where it does not, and it is
    # deliberately non-fatal so an unsupported driver does not wedge the unit.
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
