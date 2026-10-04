{ ... }: {
  # WiFi half of the 미유 network. "mini" because, unlike feature-lan-miyu,
  # there is no DNS here: clients are handed Quad9 directly by the DHCP server,
  # so the AP deliberately never touches blocky or br-services.
  #
  # Covers DHCP, routing and firewall for 192.168.145.0/24.
  flake.nixosModules.feature-wifi-miyu-mini = { lib, ... }: {
    # Shares the host network namespace (privateNetwork defaults to false) so
    # kea can bind wlp0s20f0u6 and answer real AP clients with no bridge and no
    # relay. Firewall and nftables are off: in a shared netns they would fight
    # the host ruleset. If the radio is absent this container is simply the only
    # thing that breaks - LAN DHCP is a separate process and keeps running.
    containers.wifi-kea = {
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
            # kea refuses to start if a named interface is absent, so this is
            # the one piece of the AP that genuinely requires the dongle.
            interfaces-config.interfaces = [ "wlp0s20f0u6" ];
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
                subnet = "192.168.145.0/24";
                interface = "wlp0s20f0u6";
                pools = [
                  {
                    pool = "192.168.145.2 - 192.168.145.99";
                  }
                ];
                option-data = [
                  {
                    name = "routers";
                    data = "192.168.145.1";
                  }
                  {
                    # Plain Quad9, as requested. Keeping these clients off the
                    # local blocky resolver is also what makes the no-LAN rule
                    # below cheap: nothing useful lives behind 192.168.143.0/24.
                    name = "domain-name-servers";
                    data = "9.9.9.9, 149.112.112.112";
                  }
                  {
                    name = "domain-name";
                    data = "lan";
                  }
                  {
                    name = "broadcast-address";
                    data = "192.168.145.255";
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

    # WPA3-only, no WPA2 fallback. NetworkManager derives pmf=required from
    # key-mgmt=sae, which SAE mandates anyway.
    networking.networkmanager.ensureProfiles.profiles.miyu-ap = {
      connection = {
        id = "miyu-ap";
        type = "wifi";
        interface-name = "wlp0s20f0u6";
        autoconnect = true;
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
      # Static addressing; kea (above) hands out the leases. ipv4.method=shared
      # would move DHCP and NAT inside NetworkManager and put client DNS behind
      # a local dnsmasq, which is not what we want.
      ipv4 = {
        method = "manual";
        addresses = "192.168.145.1/24";
      };
      ipv6.method = "disabled";
    };

    networking.nat = {
      enable = true;
      internalIPs = [ "192.168.145.0/24" ];
      internalInterfaces = [ "wlp0s20f0u6" ];
    };

    # AP clients get the internet and nothing else.
    #
    # This lives in its own table at priority -10 rather than in
    # networking.firewall.extraForwardRules on purpose. extraForwardRules is a
    # concatenated string, so whether these rejects land before or after
    # feature-lan-miyu's `oifname "br-services" ... accept` depends on module
    # evaluation order - and that rule accepts *anything* leaving the services
    # bridge, so getting the order wrong silently re-opens 192.168.143.0/24 to
    # the AP. A base chain at a lower priority is evaluated first, always.
    networking.nftables.tables.wifi-miyu-containment = {
      family = "inet";
      content = ''
        chain forward {
          type filter hook forward priority -10; policy accept;

          ip saddr 192.168.145.0/24 ip daddr {
            10.0.0.0/8,
            172.16.0.0/12,
            192.168.0.0/16
          } reject
        }
      '';
    };

    # An interfaces.<iface> entry with no ports makes NixOS drop everything on
    # that link except established/related, so AP clients can only reach kea for
    # a lease. Their DNS goes straight out to Quad9, never to homura.
    networking.firewall.interfaces.wlp0s20f0u6 = {
      allowedUDPPorts = [ 67 ];
    };

    systemd.services."container@wifi-kea" = {
      # A device unit stays pending until the radio shows up, so this both
      # delays the container until the dongle is enumerated and tears it down
      # again when the dongle is pulled.
      after = [
        "NetworkManager-ensure-profiles.service"
        "sys-subsystem-net-devices-wlp0s20f0u6.device"
      ];
      wants = [
        "NetworkManager-ensure-profiles.service"
        "sys-subsystem-net-devices-wlp0s20f0u6.device"
      ];
      bindsTo = [ "sys-subsystem-net-devices-wlp0s20f0u6.device" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}
