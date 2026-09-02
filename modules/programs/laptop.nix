{ pkgs, lib, ... }:

{
  programs = {
    dconf.enable = true;

    niri = {
      enable = true;
      useNautilus = false;
    };

    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-media-tags-plugin
        thunar-vcs-plugin
      ];
    };
  };
}
