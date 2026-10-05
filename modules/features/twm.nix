{ self, inputs, ... }: {
  imports = [ inputs.wrapper-modules.flakeModules.wrappers ];

  # twm's startup file is a line based language rather than a structured
  # format, so settings is raw lines like the sway wrapper. It is handed over
  # with -f, which is the first file twm looks at when given one.
  flake.wrappers.twm-m = { config, lib, pkgs, wlib, ... }: {
    imports = [ wlib.modules.default ];

    options.settings = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Contents of the twm startup file.
        Variables first, then bindings, then menus.
      '';
    };

    config = {
      package = lib.mkDefault pkgs.tab-window-manager;

      constructFiles.generatedConfig = {
        relPath = "${config.binName}rc";
        content = config.settings;
      };

      flags."-f" = config.constructFiles.generatedConfig.path;

      # Dark neutral grey with a washed desaturated teal accent. twm has no
      # config check that would run without a display, so any change here is
      # only validated by starting the session.
      settings = ''
        Color
        {
          DefaultBackground        "#141414"
          DefaultForeground        "#dedede"
          BorderColor              "#2f5c58"
          BorderTileBackground     "#1e1e1e"
          BorderTileForeground     "#2a2a2a"
          TitleBackground          "#1e1e1e"
          TitleForeground          "#dedede"
          MenuBackground           "#141414"
          MenuForeground           "#dedede"
          MenuTitleBackground      "#2f5c58"
          MenuTitleForeground      "#d9ece9"
          MenuBorderColor          "#2f5c58"
          MenuShadowColor          "#0a0a0a"
          IconBackground           "#141414"
          IconForeground           "#dedede"
          IconManagerBackground    "#1e1e1e"
          IconManagerForeground    "#dedede"
          IconManagerHighlight     "#2f5c58"
          PointerBackground        "#141414"
          PointerForeground        "#dedede"
        }

        "Return" = m4 : all : f.exec "${lib.getExe pkgs.kitty} &"
        "space" = m4 : all : f.exec "${lib.getExe' self.packages.${pkgs.stdenv.hostPlatform.system}.dmenu-m "dmenu_run"} &"
      '';

      meta.platforms = lib.platforms.linux;
    };
  };

  flake.nixosModules.feature-twm = { config, lib, pkgs, ... }: {
    # gui.nix turns xorg off for the wayland hosts.
    services.xserver.enable = lib.mkForce true;

    services.xserver.windowManager.session = [
      {
        name = "twm";
        start = ''
          if [ -f /home/m/.background ]; then
            ${lib.getExe pkgs.xwallpaper} --zoom /home/m/.background &
          fi
          ${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.twm-m} &
          waitPID=$!
        '';
      }
    ];

    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.twm-m ];
  };
}
