{ inputs, ... }: {
  imports = [ inputs.wrapper-modules.flakeModules.wrappers ];

  flake.wrappers."noctalia-m" =
    { config, lib, pkgs, wlib, ... }: {
      imports = [ wlib.modules.default ];

      options.settings = lib.mkOption {
        type = wlib.types.structuredValueWith {
          typeName = "TOML";
          nullable = false;
        };
        default = { };
        description = ''
          Configuration of noctalia v5, serialized to TOML and shipped inside
          the wrapped package.

          Noctalia v5 has no config path flag, it reads every TOML file below
          $NOCTALIA_CONFIG_HOME/noctalia, so the wrapper points
          NOCTALIA_CONFIG_HOME at the wrapper output.
        '';
      };

      config = {
        package = lib.mkDefault pkgs.noctalia;

        settings = {
          bar.default.position = "top";

          theme.mode = "dark";
        };

        # $out/noctalia/config.toml, with NOCTALIA_CONFIG_HOME pointed at $out,
        # which is wrapperPaths.placeholder minus the binary's relPath.
        constructFiles.generatedConfig = {
          content = builtins.toJSON config.settings;
          relPath = "noctalia/config.toml";
          builder = ''
            ${pkgs.remarshal}/bin/json2toml "$1" "$2"
          '';
        };

        env.NOCTALIA_CONFIG_HOME = lib.removeSuffix config.wrapperPaths.relPath config.wrapperPaths.placeholder;

        drv.installPhase = ''
          runHook preInstall

          ${lib.getExe config.package} config validate ${config.constructFiles.generatedConfig.path}

          runHook postInstall
        '';

        meta.platforms = lib.platforms.linux;
      };
    };
}
