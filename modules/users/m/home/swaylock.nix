{ config, ... }:

{
  xdg.configFile."swaylock/config".text = ''
    image=${config.home.homeDirectory}/.lock
  '';
}
