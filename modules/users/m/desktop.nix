{ pkgs, ... }:

{
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      swayidle
      swaylock
    ];
  };

  security.pam.services.swaylock = { };
}
