{ ... }: {
  flake.nixosModules.feature-ssd = { ... }: {
    services.fstrim.enable = true;
  };
}
