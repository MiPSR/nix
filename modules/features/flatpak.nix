{ ... }: {
  flake.nixosModules.feature-flatpak = { ... }: {
    services.flatpak.enable = true;
  };
}