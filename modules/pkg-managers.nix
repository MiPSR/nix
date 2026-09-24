{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    appimage-run
  ];

  services.flatpak.enable = true;
}
