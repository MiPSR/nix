{ inputs, ... }: {
  flake.nixosModules.feature-gui = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      alsa-utils
      darktable
      (discord.override { withVencord = true; })
      fooyin
      google-chrome
      helix
      heroic
      jdk
      krita
      librewolf
      opencode
      prismlauncher
      pwvucontrol
      qtscrcpy
      stoat-desktop
      thunderbird-esr
      vesktop
      wlr-randr
      inputs.super-simple-defaults.packages.x86_64-linux.default
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

    services.lact.enable = true;

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
        extraConfig.pipewire."50-clock" = {
          "context.properties" = {
            "clock.power-of-two-quantum" = false;
            "default.clock.allowed-rates" = [
              192000
              44100
            ];
            "default.clock.min-quantum" = 512;
            "default.clock.quantum" = 512;
            "default.clock.rate" = 192000;
          };
        };
        jack.enable = true;
        pulse.enable = true;
      };
      printing.enable = true;
      udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", TAG+="uaccess"
      '';
      udisks2.enable = true;
    };

    systemd.services.power-profile-default = {
      description = "Set the default power profile";
      wantedBy = [ "multi-user.target" ];
      after = [ "power-profiles-daemon.service" ];
      requires = [ "power-profiles-daemon.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver";
      };
    };
  };
}
