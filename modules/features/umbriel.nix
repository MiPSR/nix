{ self, inputs, ... }: {
  imports = [ inputs.wrapper-modules.flakeModules.wrappers ];

  flake.wrappers."umbriel-m" =
    { config, lib, pkgs, wlib, ... }: {
      imports = [ wlib.modules.default ];

      options.settings = lib.mkOption {
        type = wlib.types.structuredValueWith {
          typeName = "TOML";
          nullable = false;
        };
        default = { };
        description = ''
          Configuration of umbriel, serialized to TOML and shipped inside the
          wrapped package.

          The config is injected through XDG_CONFIG_HOME rather than the -c
          flag, because umbriel expects its subcommands (msg, validate,
          outputs, ...) before any flag, so a leading -c would swallow them.
        '';
      };

      config = {
        package = lib.mkDefault pkgs.umbriel;

        settings =
          let
            noctalia = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-m;
            kitty = lib.getExe pkgs.kitty;
          in
          {
            appearance.blur.radius = 3;

            general = {
              autostart = [
                kitty
                noctalia
              ];

              mod_key = "Super";
            };

            keybinds = {
              "Mod+D" = {
                action = "spawn:${noctalia} msg panel-toggle launcher";
                repeat = false;
              };

              "Mod+Escape" = "session-quit";

              "Mod+Q" = {
                action = "window-close";
                repeat = false;
              };

              "Mod+Return" = {
                action = "spawn:${kitty}";
                repeat = false;
              };

              "Mod+Shift+Escape" = {
                action = "shortcuts-inhibit-toggle";
                allow_when_inhibited = true;
                repeat = false;
              };
            };
          };

        # $out/umbriel/config.toml, with XDG_CONFIG_HOME pointed at $out, which
        # is wrapperPaths.placeholder minus the binary's relPath.
        constructFiles.generatedConfig = {
          content = builtins.toJSON config.settings;
          relPath = "umbriel/config.toml";
          builder = ''
            ${pkgs.remarshal}/bin/json2toml "$1" "$2"
          '';
        };

        env.XDG_CONFIG_HOME = lib.removeSuffix config.wrapperPaths.relPath config.wrapperPaths.placeholder;

        # The session launcher, desktop entry and user service all hardcode the
        # unwrapped binary's store path, so they have to be repointed or none of
        # them would actually use the config shipped here.
        filesToPatch = [
          "bin/start-umbriel"
          "lib/systemd/user/umbriel.service"
          "share/applications/*.desktop"
          "share/systemd/user/umbriel.service"
          "share/wayland-sessions/umbriel.desktop"
        ];

        drv.installPhase = ''
          runHook preInstall

          ${lib.getExe config.package} validate -c ${config.constructFiles.generatedConfig.path}

          runHook postInstall
        '';

        meta.platforms = lib.platforms.linux;
      };
    };
}
