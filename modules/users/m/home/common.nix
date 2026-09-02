{ pkgs, ... }:

{
  home.packages = with pkgs; [
    anyrun
    brightnessctl
    chromium
    jdk
    librewolf
    vesktop
  ];
}
