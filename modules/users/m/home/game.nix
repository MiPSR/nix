{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gamescope
    lsfg-vk
    lsfg-vk-ui
    prismlauncher
    protonplus
    steam
  ];
}
