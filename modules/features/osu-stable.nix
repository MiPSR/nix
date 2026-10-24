{ inputs, ... }: {
  flake.nixosModules.feature-osu-stable = { pkgs, ... }: let
    upstream = inputs.osu-stable-nixos.packages.x86_64-linux.default;
    stableFixed = pkgs.writeShellScriptBin "stable!fixed" ''
      exec ${pkgs.gamescope}/bin/gamescope -w 1600 -h 900 -r 240 -f -- osu "$@"
    '';
    stableFixedDesktop = pkgs.makeDesktopItem {
      name = "stable!fixed";
      desktopName = "stable!fixed";
      exec = "stable!fixed";
      icon = "osu-stable";
      categories = [ "Game" ];
      terminal = false;
      startupNotify = true;
      startupWMClass = "osu!.exe";
    };
  in {
    environment.systemPackages = [
      upstream
      pkgs.gamescope
      stableFixed
      stableFixedDesktop
    ];
  };
}
