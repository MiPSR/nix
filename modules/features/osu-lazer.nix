{ inputs, ... }: {
  flake.nixosModules.feature-osu-lazer = { pkgs, ... }: let
    lazerFixed = pkgs.writeShellScriptBin "lazer!fixed" ''
      exec ${pkgs.gamescope}/bin/gamescope -w 1600 -h 900 -r 240 -f -- "osu!" "$@"
    '';

    lazerFixedDesktop = pkgs.makeDesktopItem {
      name = "lazer!fixed";
      desktopName = "lazer!fixed";
      exec = "lazer!fixed";
      icon = "osu";
      categories = [ "Game" ];
      terminal = false;
      startupNotify = true;
    };
  in {
    imports = [ inputs.roxysu.nixosModules.default ];

    programs.roxysu.enable = true;

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        icu
        stdenv.cc.cc.lib
      ];
    };

    environment.systemPackages = [
      pkgs.gamescope
      pkgs.osu-lazer-bin
      lazerFixed
      lazerFixedDesktop
    ];
  };
}
