{ ... }: {
  flake.nixosModules.feature-games = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      heroic
      interlude
      prismlauncher
      protonup-rs
    ];
  };
}
