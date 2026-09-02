{ lib, ... }:

{
  home = {
    homeDirectory = lib.mkDefault "/home/m";
    stateVersion = "26.05";
    username = lib.mkDefault "m";
  };

  imports = [
    ./neovim.nix
    ./nu.nix
    ./opencode.nix
    ./starship.nix
    ./tmux.nix
  ];
}
