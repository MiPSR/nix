{ ... }: {
  flake.nixosModules.feature-umbriel = { pkgs, ... }: {
    environment = {
      etc = {
        "xdg/umbriel/config.toml".source = (pkgs.formats.toml { }).generate "umbriel-config" {
          general.autostart = [
            "noctalia"
            "sh -c \"grep -qai panasonic /sys/class/drm/*/edid && wl-gammactl -g 1.6\""
          ];

          output = {
            "Panasonic Industry Company Panasonic-TV 0x01010101" = {
              mode = "1920x1080@60";
              scale = 1.0;
            };
          };

          environment = {
            XCURSOR_SIZE = "24";
            XCURSOR_THEME = "Bibata-Modern-Ice";
          };

          input = {
            cursor = {
              size = 24;
              theme = "Bibata-Modern-Ice";
            };
            device = [
              {
                name = "HT Nulea M509";
                accel_profile = "custom 0.1 0.00000 0.10000 0.20000 0.30000 0.40000 0.50000 0.61833 0.76749 0.94025 1.13109 1.33577 1.55107 1.77448 2.00412 2.23853 2.47658 2.71744 2.96043 3.20506 3.45095 3.69780 3.94539 4.19354 4.44213 4.69105 4.94022 5.18958 5.43909 5.68872 5.93843 6.18822 6.43805 6.68792 6.93782 7.18775 7.43769 7.68764 7.93761 8.18758 8.43756 8.68755";
              }
            ];
            keyboard = {
              layout = "us";
              variant = "intl";
            };
            touchpad = {
              natural_scroll = true;
              tap = false;
            };
          };

          keybinds = {
            "Alt+Print" =
              ''spawn sh -c 'geom=$(umbriel windows | grep "^*" | head -n1 | grep -oE "[0-9]+x[0-9]+[+-][0-9]+[+-][0-9]+" | head -n1); region=$(printf "%s" "$geom" | sed -E "s/^([0-9]+)x([0-9]+)([+-][0-9]+)([+-][0-9]+)$/\3,\4 \1x\2/" | tr -d "+"); [ -n "$region" ] && grim -g "$region" - | wl-copy --type image/png && notify-send "Screenshot" "Window copied to clipboard"' '';
            "Ctrl+Alt+Delete" = "session-quit skip-confirmation";
            "Ctrl+Print" = "spawn noctalia msg screenshot-region";
            "Mod+J" = "window-cycle-primary-extent";
            "Mod+L" = "spawn noctalia msg panel-toggle session";
            "Mod+Left" = "window-focus-left";
            "Mod+Up" = "window-focus-or-workspace-up";
            "Mod+Down" = "window-focus-or-workspace-down";
            "Mod+Return" = "spawn alacritty";
            "Mod+Right" = "window-focus-right";
            "Mod+Shift+C" = "window-close";
            "Mod+Shift+F" = "spawn dolphin";
            "Mod+Space" = "spawn noctalia msg panel-toggle launcher";
            "Mod+V" = "window-toggle-floating";
            "Mod+WheelDown" = "window-focus-right";
            "Mod+WheelUp" = "window-focus-left";
            "Print" =
              ''spawn sh -c 'out=$(umbriel outputs | awk "/^[A-Za-z0-9-]+ /{o=\$1} /Focused: yes/{print o; exit}"); [ -n "$out" ] && grim -o "$out" - | wl-copy --type image/png && notify-send "Screenshot" "Screen copied to clipboard"' '';
            "XF86AudioLowerVolume" = {
              action = "spawn noctalia msg volume-down";
              allow_when_locked = true;
            };
            "XF86AudioMicMute" = "spawn wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            "XF86AudioMute" = {
              action = "spawn noctalia msg volume-mute";
              allow_when_locked = true;
              repeat = false;
            };
            "XF86AudioRaiseVolume" = {
              action = "spawn noctalia msg volume-up";
              allow_when_locked = true;
            };
            "XF86MonBrightnessDown" = "spawn brightnessctl set 5%-";
            "XF86MonBrightnessUp" = "spawn brightnessctl set +5%";
          };

        };
      };

      systemPackages = with pkgs; [
        alacritty
        bibata-cursors
        brightnessctl
        libnotify
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
        grim
        noctalia
        slurp
        wl-clipboard
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
