{ inputs, ... }: {
  flake.nixosModules.feature-super-simple-booru-bot = { ... }: {
    systemd.tmpfiles.rules = [
      "d /var/lib/super-simple-booru-bot 0700 997 997 -"
    ];

    containers.booru = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_services";
      localAddress = "192.168.244.140/24";

      bindMounts."/var/lib/super-simple-booru-bot" = {
        hostPath = "/var/lib/super-simple-booru-bot";
        isReadOnly = false;
      };

      config = { pkgs, ... }: {
        imports = [ inputs.super-simple-booru-bot.nixosModules.default ];

        system.stateVersion = "26.05";
        networking.enableIPv6 = false;
        nix.enable = false;

        networking.defaultGateway = "192.168.244.254";
        networking.nameservers = [ "192.168.244.100" ];

        users.users.super-simple-booru-bot.uid = 997;
        users.groups.super-simple-booru-bot.gid = 997;

        services.superSimpleBooruBot = {
          enable = true;
          dataDir = "/var/lib/super-simple-booru-bot";
          secretsFile = "/var/lib/super-simple-booru-bot/secrets.toml";
          dbPath = "super-simple-booru-bot.sqlite3";
        };
      };
    };

    systemd.services."container@booru" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}