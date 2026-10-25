{ ... }: {
  flake.nixosModules.feature-wireguard = { pkgs, ... }: {
    systemd.tmpfiles.rules = [
      "d /var/lib/wireguard 0700 root root -"
    ];

    containers.wireguard = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_services";
      localAddress = "192.168.244.130/24";

      bindMounts."/var/lib/wireguard" = {
        hostPath = "/var/lib/wireguard";
        isReadOnly = false;
      };

      config = { pkgs, ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;

        nix.enable = false;

        networking.defaultGateway = "192.168.244.254";
        networking.nameservers = [ "192.168.244.100" ];

        networking.firewall = {
          allowedUDPPorts = [ 51820 ];
          extraForwardRules = ''
            iifname "wg0" accept
            oifname "wg0" ct state established,related accept
          '';
        };

        networking.wireguard.interfaces.wg0 = {
          ips = [ "192.168.67.254/24" ];
          listenPort = 51820;
          privateKeyFile = "/var/lib/wireguard/private.key";
          generatePrivateKeyFile = true;

          postSetup = ''
            ${pkgs.procps}/bin/sysctl -w net.ipv4.ip_forward=1
          '';

          peers = [ ];
        };
      };
    };

    networking.firewall = {
      allowedUDPPorts = [ 51820 ];
      extraForwardRules = ''
        ip saddr 192.168.67.0/24 ip daddr 192.168.244.100 tcp dport 53 accept
        ip saddr 192.168.67.0/24 ip daddr 192.168.244.100 udp dport 53 accept
      '';
    };

    networking.nat.forwardPorts = [
      {
        sourcePort = 51820;
        destination = "192.168.244.130:51820";
        proto = "udp";
      }
    ];

    networking.nat.internalIPs = [
      "192.168.67.0/24"
    ];

    networking.interfaces.bridge_services.ipv4.routes = [
      {
        address = "192.168.67.0";
        prefixLength = 24;
        via = "192.168.244.130";
      }
    ];

    environment.systemPackages = [ pkgs.qrencode ];

    systemd.services."container@wireguard" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}
