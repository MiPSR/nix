{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btop
    fastfetch
    fd
    ffmpeg
    file
    fish
    imagemagick
    killall
    lm_sensors
    nixfmt
    ouch
    p7zip
    poppler-utils
    ripgrep
    unar
  ];
}
