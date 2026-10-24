{ ... }: {
  flake.nixosModules.feature-umbriel = { pkgs, ... }: {
    environment = {
      etc = {
        "xdg/umbriel/config.toml".source =
          (pkgs.formats.toml { }).generate "umbriel-config" {
            general.autostart = [
              "noctalia"
              "sh -c \"grep -qai panasonic /sys/class/drm/*/edid && wl-gammactl -g 1.6\""
            ];

            input.keyboard = {
              layout = "us";
              variant = "intl";
            };

            keybinds = {
              "Alt+Print" = "spawn:noctalia msg screenshot-window --copy-to-clipboard --no-save-to-file";
              "Ctrl+Alt+Delete" = "session-quit:skip-confirmation";
              "Ctrl+Print" = "spawn:noctalia msg screenshot-region --copy-to-clipboard --no-save-to-file";
              "Mod+Shift+F" = "spawn:dolphin";
              "Mod+J" = "window-cycle-primary-extent";
              "Mod+L" = "spawn:noctalia msg panel-toggle session";
              "Mod+Left" = "window-focus-left";
              "Mod+Return" = "spawn:alacritty";
              "Mod+Right" = "window-focus-right";
              "Mod+Shift+C" = "window-close";
              "Mod+Space" = "spawn:noctalia msg panel-toggle launcher";
              "Mod+V" = "window-toggle-floating";
              "Mod+WheelDown" = "window-focus-right";
              "Mod+WheelUp" = "window-focus-left";
              "Print" = "spawn:noctalia msg screenshot-fullscreen --copy-to-clipboard --no-save-to-file";
              "XF86AudioLowerVolume" = {
                action = "spawn:noctalia msg volume-down";
                allow_when_locked = true;
              };
              "XF86AudioMicMute" = "spawn:wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              "XF86AudioMute" = {
                action = "spawn:noctalia msg volume-mute";
                allow_when_locked = true;
                repeat = false;
              };
              "XF86AudioRaiseVolume" = {
                action = "spawn:noctalia msg volume-up";
                allow_when_locked = true;
              };
              "XF86MonBrightnessDown" = "spawn:brightnessctl set 5%-";
              "XF86MonBrightnessUp" = "spawn:brightnessctl set +5%";
            };

            include.optional.files = [ "/home/m/.config/umbriel/noctalia.toml" ];
          };
      };

      systemPackages = with pkgs; [
        alacritty
        brightnessctl
        kdePackages.ark
        kdePackages.breeze
        kdePackages.dolphin
        kdePackages.dolphin-plugins
        kdePackages.ffmpegthumbs
        kdePackages.filelight
        kdePackages.gwenview
        kdePackages.kate
        kdePackages.kdialog
        kdePackages.okular
        kdePackages.xdg-desktop-portal-kde
        noctalia
        wl-gammactl
      ];
    };

    programs = {
      dconf.enable = true;
      umbriel.enable = true;
    };

    services = {
      displayManager.noctalia-greeter.enable = true;
      xserver.enable = false;
    };

    xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
}
