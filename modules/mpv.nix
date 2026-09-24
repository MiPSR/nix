{ pkgs, ... }:

{
  environment.etc = {
    "mpv/input.conf".text = ''
      LEFT seek -5
      RIGHT seek 5
      SPACE cycle pause
      ctrl+1 cycle audio
      ctrl+2 cycle sub
      ctrl+f cycle fullscreen
    '';

    "mpv/mpv.conf".text = ''
      cursor-autohide=no
      input-default-bindings=no
      input-vo-keyboard=no
      osc=no
      osd-level=0
      save-position-on-quit=no
    '';
  };

  environment.systemPackages = [ pkgs.mpv ];
}
