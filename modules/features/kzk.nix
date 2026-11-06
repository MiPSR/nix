{ self, ... }: {
  flake.nixosModules.feature-user-kzk = { pkgs, ... }: {
    users.groups.ai = { };

    users.users.kzk = {
      description = "古関ウイ";
      group = "ai";
      hashedPasswordFile = "/dev/null";
      home = "/home/kzk";
      isSystemUser = true;
      shell = pkgs.bashInteractive;
    };
  };
}
