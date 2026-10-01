{ self, inputs, ... }: {
  imports = [ inputs.wrapper-modules.flakeModules.wrappers ];

  flake.wrappers.noctalia-m = { config, lib, pkgs, wlib, ... }: {
    imports = [ wlib.modules.default ];

    options.settings = lib.mkOption {
      type = wlib.types.structuredValueWith {
        typeName = "TOML";
        nullable = false;
      };
      default = { };
      description = ''
        Noctalia v5 settings, serialised to TOML.

        Noctalia v5 has no config path flag, it reads every TOML file below
        NOCTALIA_CONFIG_HOME, so the wrapper points that at its own output.
      '';
    };

    config = {
      package = lib.mkDefault pkgs.noctalia;

      constructFiles.generatedConfig = {
        relPath = "noctalia/config.toml";
        content = builtins.toJSON config.settings;
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

  flake.nixosModules.feature-noctalia-m = { pkgs, ... }: {
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-m ];
  };
}
