{ ... }: {
  flake.nixosModules.feature-gui = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      collabora-desktop
      darktable
      (discord.override { withVencord = true; })
      jdk
      kdePackages.elisa
      kdePackages.falkon
      kdePackages.kaddressbook
      kdePackages.kate
      kdePackages.kclock
      kdePackages.kdepim-addons
      kdePackages.kmail
      krita
      librewolf
      qtscrcpy
      stoat-desktop
    ];

    hardware.opentabletdriver.enable = true;

    i18n.inputMethod = {
      enable = true;

      fcitx5 = {
        addons = with pkgs; [ fcitx5-mozc ];
        waylandFrontend = true;
      };
      type = "fcitx5";
    };

    security.rtkit.enable = true;

    services = {
      displayManager.noctalia-greeter.enable = true;

      pipewire = {
        alsa = {
          enable = true;
          support32Bit = true;
        };

        enable = true;

        jack.enable = true;

        pulse.enable = true;
      };
      power-profiles-daemon.enable = true;
      udisks2.enable = true;
    };
  };
}
