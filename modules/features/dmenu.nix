{ self, inputs, ... }: {
  imports = [ inputs.wrapper-modules.flakeModules.wrappers ];

  # dmenu has no config file, everything is command line flags, so settings is a
  # structured set which is mapped onto them. dmenu_run gets the same flags via
  # a mirrored variant, since it forwards its arguments to dmenu.
  flake.wrappers.dmenu-m = { config, lib, pkgs, wlib, ... }: {
    imports = [ wlib.modules.default ];

    options.settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          font = lib.mkOption {
            type = lib.types.str;
            default = "RobotoMono Nerd Font-11";
            description = "Font passed to -fn.";
          };
          bottom = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Render the bar along the bottom edge (-b).";
          };
          normal.bg = lib.mkOption {
            type = lib.types.str;
            default = "#141414";
            description = "Background of unselected entries (-nb).";
          };
          normal.fg = lib.mkOption {
            type = lib.types.str;
            default = "#dedede";
            description = "Foreground of unselected entries (-nf).";
          };
          selected.bg = lib.mkOption {
            type = lib.types.str;
            default = "#2f5c58";
            description = "Background of the selected entry (-sb).";
          };
          selected.fg = lib.mkOption {
            type = lib.types.str;
            default = "#d9ece9";
            description = "Foreground of the selected entry (-sf).";
          };
        };
      };
      default = { };
      description = ''
        dmenu invocation flags.
        Dark neutral grey with a washed desaturated teal selection.
      '';
    };

    config = {
      package = lib.mkDefault pkgs.dmenu;

      flags = {
        "-fn" = config.settings.font;
        "-nb" = config.settings.normal.bg;
        "-nf" = config.settings.normal.fg;
        "-sb" = config.settings.selected.bg;
        "-sf" = config.settings.selected.fg;
        "-b" = config.settings.bottom;
      };

      wrapperVariants.dmenu_run = { };

      meta.platforms = lib.platforms.linux;
    };
  };

  flake.nixosModules.feature-dmenu = { pkgs, ... }: {
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.dmenu-m ];
  };
}
