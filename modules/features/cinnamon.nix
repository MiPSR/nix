{ ... }: {
  flake.nixosModules.feature-cinnamon = { lib, ... }: {
    # gui.nix turns xorg off for the wayland hosts.
    services.xserver.enable = lib.mkForce true;

    services.xserver.desktopManager.cinnamon.enable = true;
  };
}
