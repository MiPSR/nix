{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;

    fontconfig.enable = true;

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
