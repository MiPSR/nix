{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_zen;

  environment.systemPackages = with pkgs; [
    alcom
    bs-manager
    darktable
    (discord.override { withVencord = true; })
    gamescope
    git
    google-chrome
    heroic
    interlude
    jdk
    kdePackages.elisa
    kdePackages.falkon
    kdePackages.kaddressbook
    kdePackages.kate
    kdePackages.kclock
    kdePackages.kdepim-addons
    kdePackages.kmail
    krita
    libreoffice-qt
    librewolf
    mpv
    openutau
    osu-lazer-bin
    pixelorama
    prismlauncher
    protonup-rs
    steam
    stoat-desktop
    wayvr
    wivrn
  ];

  hardware = {
    alsa.enablePersistence = true;
    amdgpu.opencl.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  imports = [ ./ui/default.nix ];

  networking.firewall = {
    allowedTCPPorts = [ 9757 ];
    allowedUDPPorts = [ 9757 ];
  };

  networking.hostName = "ui";

  services.power-profiles-daemon.enable = true;

  system.stateVersion = "26.05";
}
