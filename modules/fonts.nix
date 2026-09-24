{ pkgs, ... }:

{
  boot.plymouth.font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";

  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v14b.psf.gz";
    keyMap = "us-acentos";
    packages = [ pkgs.terminus_font ];
  };

  fonts = {
    fontDir.enable = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "Roboto Mono" ];
        sansSerif = [ "Roboto" ];
        serif = [ "Roboto Serif" ];
      };
    };
    packages = with pkgs; [
      nerd-fonts.roboto-mono
      nerd-fonts.symbols-only
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      roboto
      roboto-mono
      roboto-serif
    ];
  };
}
