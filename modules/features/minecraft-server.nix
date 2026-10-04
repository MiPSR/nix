{ self, ... }: {
  flake.nixosModules.feature-minecraft-server = { ... }: {
    containers.minecraft = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "br-services";
      localAddress = "192.168.143.110/24";

      config = { pkgs, ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;

        nix.enable = false;

        networking.defaultGateway = "192.168.143.254";
        networking.nameservers = [ "192.168.143.100" ];

        # Container-local firewall defaults to drop; the host's br-services
        # allowed*Ports do not reach into this netns.
        networking.firewall.allowedTCPPorts = [ 25565 ];
        networking.firewall.allowedUDPPorts = [ 25565 ];

        users.users.minecraft = {
          isSystemUser = true;
          group = "minecraft";
          home = "/var/lib/minecraft";
        };

        users.groups.minecraft = { };

        systemd.tmpfiles.rules = [ "d /var/lib/minecraft 0770 minecraft minecraft -" ];

        systemd.services.minecraft-server = {
          description = "Minecraft Fabric Server";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          path = [
            pkgs.jdk
            pkgs.coreutils
          ];

          serviceConfig = {
            User = "minecraft";
            Group = "minecraft";
            WorkingDirectory = "/var/lib/minecraft";
            ExecStart = "${pkgs.jdk}/bin/java -Xms10G -Xmx10G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+DisableExplicitGC -jar server.jar nogui";
            Restart = "on-failure";
            RestartSec = 10;
            SuccessExitStatus = [
              0
              130
              143
            ];
          };
        };
      };
    };

    systemd.services."container@minecraft" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}
