{ ... }: {
  flake.nixosModules.feature-cinnamon = { ... }: {
    services.xserver.enable = true;

    services.xserver.displayManager.startx.enable = true;

    services.xserver.desktopManager.cinnamon.enable = true;
  };
}
