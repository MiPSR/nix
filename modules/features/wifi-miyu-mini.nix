{ ... }: {
  # WiFi half of the 미유 network. "mini" because, unlike feature-lan-miyu,
  # there is no DNS here: clients are handed Quad9 directly by the DHCP server,
  # so the AP deliberately never touches blocky or bridge_services.
  #
  #   192.168.100.0/24  wifi clients - homura .254, kea container .100, clients .1-.99
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
        networking.nameservers = [
          "9.9.9.9"
          "149.112.112.112"
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
                    # Plain Quad9, as requested. Keeping these clients off the
                    # local blocky resolver is also what makes the no-LAN rule
                    # below cheap: nothing useful lives behind 192.168.244.0/24.
                    name = "domain-name-servers";
                    data = "9.9.9.9, 149.112.112.112";
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

    networking.nat = {
      enable = true;
      internalIPs = [ "192.168.100.0/24" ];
      internalInterfaces = [ "bridge_wifi_100" ];
    };

    # The dashboard on bridge_services is the one thing the WiFi side may reach.
    networking.firewall.extraForwardRules = ''
      ip saddr 192.168.100.0/24 ip daddr 192.168.244.101 tcp dport 80 accept
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
    # dashboard stays reachable.
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
