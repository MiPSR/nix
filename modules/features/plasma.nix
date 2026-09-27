{ ... }: {
  flake.nixosModules.feature-plasma = { pkgs, ... }: {
    environment.plasma6.excludePackages = with pkgs; [ kdePackages.discover ];

    services.desktopManager.plasma6.enable = true;
  };
}
