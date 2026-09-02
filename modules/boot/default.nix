{ pkgs, ... }:

{
  boot = {
    consoleLogLevel = 3;

    initrd = {
      systemd.enable = true;
      verbose = false;
    };

    kernel.sysctl = {
      "vm.swappiness" = 190;
    };

    kernelParams = [
      "boot.shell_on_fail"
      "intremap=on"
      "quiet"
      "rd.systemd.show_status=auto"
      "splash"
      "udev.log_priority=3"
    ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        consoleMode = "max";
        enable = true;
      };
    };

    plymouth = {
      enable = true;
      font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";
      logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png";
      theme = "bgrt";
    };
  };
}
