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
            keyboard = {
              layout = "us";
              variant = "intl";
            };
            touchpad.tap = false;
          };

          keybinds = {
            "Alt+Print" =
              ''spawn:sh -c 'geom=$(umbriel windows | grep "^*" | head -n1 | grep -oE "[0-9]+x[0-9]+[+-][0-9]+[+-][0-9]+" | head -n1); region=$(printf "%s" "$geom" | sed -E "s/^([0-9]+)x([0-9]+)([+-][0-9]+)([+-][0-9]+)$/\3,\4 \1x\2/" | tr -d "+"); [ -n "$region" ] && grim -g "$region" - | wl-copy --type image/png && notify-send "Screenshot" "Window copied to clipboard"' '';
            "Ctrl+Alt+Delete" = "session-quit:skip-confirmation";
            "Ctrl+Print" =
              ''spawn:sh -c 'geom=$(slurp); [ -n "$geom" ] && grim -g "$geom" - | wl-copy --type image/png && notify-send "Screenshot" "Region copied to clipboard"' '';
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
            "Print" =
              ''spawn:sh -c 'out=$(umbriel outputs | awk "/^[A-Za-z0-9-]+ /{o=\$1} /Focused: yes/{print o; exit}"); [ -n "$out" ] && grim -o "$out" - | wl-copy --type image/png && notify-send "Screenshot" "Screen copied to clipboard"' '';
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
