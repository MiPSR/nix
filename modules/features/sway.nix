{ self, inputs, ... }: {
  imports = [ inputs.wrapper-modules.flakeModules.wrappers ];

  # Sway's config is a line based command language rather than a structured
  # format, so this is raw lines rather than an attrset like the TOML ones. It
  # goes to etc/sway/config, which is where the NixOS sway module points
  # /etc/sway/config, the last path sway looks at. There is no sway config env
  # var and its desktop entry uses a bare `Exec=sway`, so nothing needs patching.
  flake.wrappers.sway-m = { config, lib, pkgs, wlib, ... }: {
    imports = [ wlib.modules.default ];

    options.settings = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Sway configuration, starting from the packaged default.";
    };

    config = {
      package = lib.mkDefault pkgs.sway;

      # services.displayManager.sessionPackages only accepts packages with
      # provided sessions, and passthru is not inherited from the wrapped
      # package.
      passthru.providedSessions = config.package.providedSessions;

      settings = ''
        include ${config.package}/etc/sway/config
        exec ${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-m}
      '';

      constructFiles.generatedConfig = {
        relPath = "etc/sway/config";
        content = config.settings;
        # sway already ships an etc/sway/config, so clear it before writing.
        builder = ''
          rm -f "$2"
          cp "$1" "$2"
        '';
      };

      # sway re-execs itself under dbus-run-session when it has no session bus,
      # even for -C, so hand it a bus that is already running.
      drv = {
        nativeBuildInputs = [ pkgs.dbus ];

        installPhase = ''
          runHook preInstall

          export XDG_RUNTIME_DIR=$(mktemp -d)
          chmod 700 "$XDG_RUNTIME_DIR"
          export DBUS_SESSION_BUS_ADDRESS="$(${lib.getExe' pkgs.dbus "dbus-daemon"} \
            --config-file=${pkgs.dbus}/share/dbus-1/session.conf \
            --print-address --fork)"
          export WLR_BACKENDS=headless

          ${config.package}/bin/.sway-wrapped -C -c ${config.constructFiles.generatedConfig.path}

          runHook postInstall
        '';
      };

      meta.platforms = lib.platforms.linux;
    };
  };

  flake.nixosModules.feature-sway-m = { pkgs, ... }: {
    programs.sway = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.sway-m;
    };
  };
}
