{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gnupg
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  users.users.m = {
    description = "Kévin";
    home = "/home/m";
    isNormalUser = true;
    shell = pkgs.nushell;
  };
}
