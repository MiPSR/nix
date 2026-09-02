{ hostname, pkgs, ... }:

let
  palette = import ./m-palette.nix hostname;

  # Connector names per host, from niri/outputs/<hostname>.kdl.
  wallpaperMonitors = {
    roxy = [ "eDP-1" ];
  };
in

{
  xdg.configFile."wayle/config.toml".source = (pkgs.formats.toml { }).generate "wayle-config" {
    styling = {
      # Matches bar.scale; panels use --global-scale, the bar uses --bar-scale,
      # so this leaves bar sizing untouched.
      scale = 0.8;

      rounding = "none";

      palette = {
        bg = palette.black;
        surface = palette.black;
        elevated = palette.black;
        fg = palette.light;
        fg-muted = palette.dark;
        primary = palette.accent;
        red = palette.accent;
        yellow = palette.accent;
        green = palette.accent;
        blue = palette.accent;
      };
    };

    bar = {
      scale = 0.8;
      bg = palette.accentBright;
      padding = 0.0;
      padding-ends = 0.0;
      module-gap = 0.0;
      button-group-module-gap = 0.0;

      button-rounding = "none";
      button-group-rounding = "none";
      button-group-background = palette.black;

      layout = [{
        monitor = "*";
        left = [
          "dashboard"
          "window-title"
        ];
        center = [];
        right = [
          "notifications"
          "systray"
          "volume"
          "microphone"
          "bluetooth"
          "network"
          "battery"
          "clock"
        ];
      }];
    };

    modules.clock.format = "%H:%M";

    # Replaces wbg: same wallpaper (~/.background) and fill mode on every
    # connected output.
    wallpaper.monitors = map
      (name: {
        inherit name;
        wallpaper = "/home/m/.background";
        fit-mode = "fill";
      })
      wallpaperMonitors.${hostname};
  };

  # Panel borders follow the terminal palette (accent-tinted) instead of the
  # default neutral gray mixes. Section removal is built into the
  # wayle-lite fork source; GTK CSS cannot hide widgets.
  xdg.configFile."wayle/styles/index.scss" = {
    text = ''
      :root {
        --border-subtle: color-mix(in srgb, var(--palette-primary) 25%, transparent);
        --border-default: color-mix(in srgb, var(--palette-primary) 40%, var(--palette-bg));
        --border-strong: color-mix(in srgb, var(--palette-primary) 60%, var(--palette-bg));
      }
    '';
    force = true;
  };
}
