{ pkgs, ... }:

{
  home.stateVersion = "26.05";
  imports = [ ./home/nu.nix ./home/helix.nix ];
}
