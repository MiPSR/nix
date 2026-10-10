{ ... }: {
  flake.nixosModules.feature-gui = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      alsa-utils
      darktable
      (discord.override { withVencord = true; })
      jdk
      krita
      librewolf
      qtscrcpy
      stoat-desktop
    ];

    fonts = {
      fontDir.enable = true;

      fontconfig = {
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [
            "Roboto Mono"
            "RobotoMono Nerd Font"
          ];
          sansSerif = [
            "Noto Sans CJK JP"
            "Roboto"
          ];
          serif = [
            "Noto Serif CJK JP"
            "Roboto Serif"
          ];
        };
        enable = true;
      };

      packages = with pkgs; [
        nerd-fonts.roboto-mono
        nerd-fonts.symbols-only
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        roboto
        roboto-mono
        roboto-serif
      ];
    };

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
