{ ... }: {
  flake.nixosModules.feature-mate = { ... }: {
    services.xserver.enable = true;
    services.xserver.desktopManager.mate.enable = true;
  };
}