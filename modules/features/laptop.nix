{ ... }: {
  flake.nixosModules.feature-laptop = { ... }: {
    hardware.bluetooth.enable = true;
    services.upower.enable = true;
  };
}
