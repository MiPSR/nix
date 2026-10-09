{ ... }: {
  flake.nixosModules.feature-vaultwarden = { ... }: {
    # Vaultwarden, the vault that used to run as a docker compose stack on
    # another machine (see the backup in ~/01-10-2026/bitwarden).
    #
    # Nixpkgs builds the server itself (pkgs.vaultwarden, from source) and
    # ships the web vault separately (pkgs.vaultwarden-webvault); nothing from
    # the docker image is reused except the data directory.
    #
    # The data lives on the host at /var/lib/vaultwarden rather than inside
    # the container root, so it survives a rebuild of the container exactly
    # like the minecraft worlds do. Same path on both sides.
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

      # Mail credentials, for password resets and 2FA enrolment. Kept in a
      # root-owned file on the host and bind-mounted in read-only, so the
      # password never reaches the nix store or the git repository. Create it
      # with mode 0600 before the first rebuild.
      bindMounts."/run/secrets/vaultwarden.env" = {
        hostPath = "/etc/vaultwarden/secrets.env";
        isReadOnly = true;
      };

      config =
        { ... }:
        let
          # The module allocates this uid dynamically. Pinned so the
          # bind-mounted host directory has a known owner: copy the old
          # vw-data in as uid 1000 and the service can write it as is.
          vaultwardenUid = 1000;
        in
        {
          system.stateVersion = "26.05";

          networking.enableIPv6 = false;

          nix.enable = false;

          networking.defaultGateway = "192.168.244.254";
          networking.nameservers = [ "192.168.244.100" ];

          # Container-local firewall defaults to drop; the host's
          # bridge_services allowed*Ports do not reach into this netns. Only
          # caddy, next door on the same bridge, needs to reach this.
          networking.firewall.allowedTCPPorts = [ 80 ];

          users.users.vaultwarden.uid = vaultwardenUid;
          users.groups.vaultwarden.gid = vaultwardenUid;

          services.vaultwarden = {
            enable = true;

            # Read by PID 1 before ExecStart, same as any other EnvironmentFile.
            environmentFile = [ "/run/secrets/vaultwarden.env" ];

            config = {
              DOMAIN = "https://vault.cunny.fr";
              SIGNUPS_ALLOWED = false;

              # The module defaults to ::1. This namespace is IPv4-only, so
              # that would leave the server bound to an address it does not
              # have.
              ROCKET_ADDRESS = "0.0.0.0";
              ROCKET_PORT = 80;

              # caddy proxies websockets transparently, but vaultwarden only
              # serves the notification hub when this is on.
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
