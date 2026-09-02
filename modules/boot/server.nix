{ pkgs, ... }:

{
  imports = [ ./default.nix ];

  boot.kernelPackages = pkgs.linuxPackages_hardened;
}
