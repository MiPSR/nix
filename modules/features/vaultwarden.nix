{ ... }: {
  flake.nixosModules.feature-vaultwarden = { ... }: {
    containers.vaultwarden = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_services";
      localAddress = "192.168.244.120/24";

      bindMounts."/var/lib/vaultwarden" = {
        hostPath = "/var/lib/vaultwarden";
        isReadOnly = false;
      };

      bindMounts."/run/secrets/vaultwarden.env" = {
        hostPath = "/etc/vaultwarden/secrets.env";
        isReadOnly = true;
      };

      config =
        { ... }:
        let
          vaultwardenUid = 1000;
        in
        {
          system.stateVersion = "26.05";

          networking.enableIPv6 = false;

          nix.enable = false;

          networking.defaultGateway = "192.168.244.254";
          networking.nameservers = [ "192.168.244.100" ];

          networking.firewall.allowedTCPPorts = [
            8000
          ];

          users.users.vaultwarden.uid = vaultwardenUid;
          users.groups.vaultwarden.gid = vaultwardenUid;

          services.vaultwarden = {
            enable = true;

            environmentFile = [ "/run/secrets/vaultwarden.env" ];

            config = {
              DOMAIN = "https://vault.cunny.fr";
              SIGNUPS_ALLOWED = false;

              ROCKET_ADDRESS = "0.0.0.0";

              ENABLE_WEBSOCKET = true;
            };
          };
        };
    };

    systemd.services."container@vaultwarden" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}
