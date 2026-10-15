{ self, ... }: {
  flake.nixosModules.feature-games = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gamescope
      heroic
      interlude
      prismlauncher
      protonup-rs
      steam
    ];
  };
}
