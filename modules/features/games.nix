{ self, ... }: {
  flake.nixosModules.feature-games = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gamescope
      heroic
      interlude
      osu-lazer-bin
      prismlauncher
      protonup-rs
      steam
    ];
  };
}
