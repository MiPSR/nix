{ self, inputs, ... }: {
  flake.nixosModules.feature-niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri-m;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.niri-m = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        binds = {
          "Mod+Q".close-window = [];
          "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
          "Mod+S".spawn-sh = "${lib.getExe self'.packages.noctalia-m} msg panel-toggle launcher";
        };

        input.keyboard.xkb.layout = "us";

        layout.gaps = 5;

        spawn-at-startup = [
          (lib.getExe self'.packages.noctalia-m)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
      };
    };
  };
}
