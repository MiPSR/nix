{
  flake.nixosModules.profile-gnome = { pkgs, ... }: {
    environment.gnome.excludePackages = with pkgs; [
      gnome-software
    ];

    services.desktopManager.gnome.enable = true;

    services.displayManager.defaultSession = "gnome";

    services.displayManager.gdm.enable = true;

    environment.systemPackages = with pkgs; [
      evolution
    ];
  };
}
