{ self, ... }: {
  flake.nixosModules.feature-minecraft-server = { ... }: {
    containers.minecraft = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "br-services";
      localAddress = "192.168.143.110/24";

      bindMounts."/var/lib/minecraft" = {
        isReadOnly = false;
      };

      config = { pkgs, ... }: {
        system.stateVersion = "26.05";

        networking.enableIPv6 = false;

        nix.enable = false;

        networking.interfaces.eth0.ipv4.routes = [
          {
            address = "0.0.0.0";
            prefixLength = 0;
            via = "192.168.143.254";
          }
        ];

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

    systemd.services."container@minecraft".serviceConfig = {
      CPUWeight = 80;
      MemoryMax = "12G";
    };
  };
}
