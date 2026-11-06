{ ... }: {
  flake.nixosModules.feature-laptop = { ... }: {
    hardware.bluetooth.enable = true;
  };
}
