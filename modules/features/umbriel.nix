{ self, inputs, ... }: {
  imports = [ inputs.wrapper-modules.flakeModules.wrappers ];

  # umbriel 0.1.0 has no offline config validation, the `umbriel config validate`
  # subcommand the docs mention only exists in newer builds, so unlike the niri
  # wrapper there is nothing to run in installPhase.
  flake.wrappers.umbriel-m = { config, lib, pkgs, wlib, ... }: {
    imports = [ wlib.modules.default ];

    options.settings = lib.mkOption {
      type = wlib.types.structuredValueWith {
        typeName = "TOML";
        nullable = false;
      };
      default = { };
      description = ''
        Umbriel settings, serialised to TOML.

        Umbriel reads $XDG_CONFIG_HOME/umbriel/config.toml, then
        $XDG_CONFIG_DIRS/umbriel/config.toml, then the packaged config, so the
        wrapper prepends its own output to XDG_CONFIG_DIRS. `umbriel -c` is
        deliberately not used, umbriel parses its subcommand before any flag, so
        a prepended -c would break `umbriel msg <action>`.
      '';
    };

    config = {
      package = lib.mkDefault pkgs.umbriel;

      settings.general.autostart = [
        (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-m)
      ];

      constructFiles.generatedConfig = {
        relPath = "umbriel/config.toml";
        content = builtins.toJSON config.settings;
        builder = ''
          ${pkgs.remarshal}/bin/json2toml "$1" "$2"
        '';
      };

      # pkgs.umbriel's own wrapper puts xwayland-satellite on PATH. This wrapper
      # replaces that wrapper, so the injection is lost unless it is re-added
      # here. Umbriel's general.xwayland defaults to true and cannot start
      # without it.
      runtimePkgs = [ pkgs.xwayland-satellite ];

      # services.displayManager.sessionPackages only accepts packages with
      # provided sessions, and passthru is not inherited from the wrapped
      # package.
      passthru.providedSessions = config.package.providedSessions;

      prefixVar = [
        [
          "XDG_CONFIG_DIRS"
          ":"
          (lib.removeSuffix config.wrapperPaths.relPath config.wrapperPaths.placeholder)
        ]
      ];

      # The session launcher, desktop entry and user service all hardcode the
      # unwrapped binary's store path, so they have to be repointed or none of
      # them would run the wrapped one.
      filesToPatch = [
        "bin/start-umbriel"
        "share/systemd/user/umbriel.service"
        "share/wayland-sessions/umbriel.desktop"
      ];

      meta.platforms = lib.platforms.linux;
    };
  };

  flake.nixosModules.feature-umbriel-m = { pkgs, ... }: {
    programs.umbriel = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.umbriel-m;
    };
  };
}
