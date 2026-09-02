{ ... }:

{
  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "Roboto Mono" ];
      sansSerif = [ "Roboto" ];
      serif = [ "Roboto Serif" ];
    };
  };
}
