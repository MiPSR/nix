{
  flake.nixosModules.profile-plasma = { pkgs, ... }: {
    environment.plasma6.excludePackages = with pkgs; [
      kdePackages.discover
      kdePackages.kwin-x11
    ];

    services.desktopManager.plasma6.enable = true;

    services.displayManager.defaultSession = "plasma";

    services.displayManager.plasma-login-manager.enable = true;

    environment.systemPackages = with pkgs; [
      kdePackages.falkon
      kdePackages.kaddressbook
      kdePackages.kclock
      kdePackages.kdepim-addons
      kdePackages.kmail
    ];
  };
}
