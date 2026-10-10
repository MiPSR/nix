{ self, ... }: {
  flake.nixosModules.feature-minecraft-server = { ... }: {
    containers.minecraft = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_services";
      localAddress = "192.168.244.110/24";

      bindMounts."/var/lib/minecraft" = {
        hostPath = "/var/lib/minecraft";
        isReadOnly = false;
      };

      config = { pkgs, ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;

        nix.enable = false;

        networking.defaultGateway = "192.168.244.254";
        networking.nameservers = [ "192.168.244.100" ];

        networking.firewall.allowedTCPPorts = [ 25565 ];
        networking.firewall.allowedUDPPorts = [ 25565 ];

        users.users.minecraft = {
          isSystemUser = true;
          group = "minecraft";
          home = "/var/lib/minecraft";
          uid = 999;
        };

        users.groups.minecraft.gid = 999;

        systemd.tmpfiles.rules = [ "d /var/lib/minecraft 0770 minecraft minecraft -" ];

        systemd.services.minecraft-server = {
          description = "Minecraft Fabric Server";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          path = [
            pkgs.jdk25_headless
            pkgs.coreutils
          ];

          serviceConfig = {
            User = "minecraft";
            Group = "minecraft";
            WorkingDirectory = "/var/lib/minecraft";
            ExecStart = "${pkgs.jdk25_headless}/bin/java -Xms10G -Xmx10G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+DisableExplicitGC -jar server.jar nogui";
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
