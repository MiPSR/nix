{ ... }: {
  flake.nixosModules.feature-plasma = { pkgs, ... }: {
    environment.plasma6.excludePackages = with pkgs.kdePackages; [ discover ];
    environment.systemPackages = with pkgs; [
      kdePackages.kdialog
    ];
    services.desktopManager.plasma6.enable = true;
    services.displayManager.plasma-login-manager.enable = true;
    services.xserver.enable = false;
  };
}