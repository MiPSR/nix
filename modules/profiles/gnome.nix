{
  flake.nixosModules.profile-gnome = { pkgs, ... }: {
    environment.gnome.excludePackages = with pkgs; [
      gnome-software
    ];

    services.desktopManager.gnome.enable = true;

    services.displayManager.defaultSession = "gnome";

    environment.systemPackages = with pkgs; [
      evolution
    ];
  };
}
