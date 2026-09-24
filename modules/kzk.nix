{ pkgs, ... }:

{
  users.users.kzk = {
    description = "古関ウイ";
    hashedPasswordFile = "/dev/null";
    home = "/home/kzk";
    isSystemUser = true;
  };
}
