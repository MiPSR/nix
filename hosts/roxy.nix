{ config, pkgs, ... }:

{
  hardware = {
    alsa.enablePersistence = true;
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        gst_all_1.gst-plugins-bad
        libva
        libva-vdpau-driver
        libvdpau-va-gl
        libvpx
        mesa
        rocmPackages.clr.icd
      ];
      extraPackages32 = with pkgs.driversi686Linux; [
        libva-vdpau-driver
        libvdpau-va-gl
        mesa
      ];
    };
  };

  networking.hostName = "roxy";

  profile = "laptop";

  services.fprintd.enable = true;

  security.pam.services.swaylock.rules.auth.fprintd.order =
    config.security.pam.services.swaylock.rules.auth.unix.order + 50;

  system.stateVersion = "26.05";

  users.users.m.extraGroups = [
    "networkmanager"
    "wheel"
  ];
}
