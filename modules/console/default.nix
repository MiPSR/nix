{ pkgs, ... }:

{
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v14b.psf.gz";
    keyMap = "us-acentos";
    packages = [ pkgs.terminus_font ];
  };
}
