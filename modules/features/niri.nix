{ self, inputs, ... }: {
  imports = [ inputs.wrapper-modules.flakeModules.wrappers ];

  flake.wrappers.niri-m = { config, lib, pkgs, wlib, ... }: {
    imports = [ inputs.wrapper-modules.wrapperModules.niri ];

    settings = {
      binds = {
        "Mod+Q".close-window = [ ];
        "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
        "Mod+S".spawn-sh = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-m} msg panel-toggle launcher";
      };

      input.keyboard.xkb.layout = "us";

      layout.gaps = 5;

      spawn-at-startup = [
        (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-m)
      ];

      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
    };
  };

  flake.nixosModules.feature-niri-m = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri-m;
    };
  };
}
