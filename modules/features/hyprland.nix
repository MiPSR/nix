{ self, inputs, ... }: {
  imports = [ inputs.wrapper-modules.flakeModules.wrappers ];

  # Hyprland 0.55 deprecated hyprlang in favour of Lua, so this is a Lua script
  # rather than a structured format. The .lua extension is what selects the Lua
  # parser, so the file has to keep it.
  flake.wrappers.hyprland-m = { config, lib, pkgs, wlib, ... }: {
    imports = [ wlib.modules.default ];

    options.settings = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Hyprland Lua configuration.

        Pointed at by HYPRLAND_CONFIG. Starting a program is
        `hl.on("hyprland.start", function() hl.exec_cmd("...") end)`, `exec`
        and `exec-once` only exist in the legacy hyprlang parser.
      '';
    };

    config = {
      package = lib.mkDefault pkgs.hyprland;
      binName = "Hyprland";

      # pkgs.hyprland wrapPrograms these onto PATH, and this wrapper replaces
      # that wrapper, so they are re-added here.
      runtimePkgs = [
        pkgs.binutils
        pkgs.hyprland-qtutils
        pkgs.pciutils
        pkgs.pkgconf
      ];

      # services.displayManager.sessionPackages only accepts packages with
      # provided sessions, and passthru is not inherited from the wrapped
      # package.
      passthru.providedSessions = config.package.providedSessions;

      settings = ''
        hl.on("hyprland.start", function()
            hl.exec_cmd("${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-m}")
        end)
      '';

      constructFiles.generatedConfig = {
        relPath = "hyprland.lua";
        content = config.settings;
      };

      env.HYPRLAND_CONFIG = config.constructFiles.generatedConfig.path;

      # The session desktop entry hardcodes the unwrapped binary's store path.
      filesToPatch = [ "share/wayland-sessions/hyprland.desktop" ];

      # --verify-config aborts on a missing XDG_RUNTIME_DIR before it reads the
      # config, and it does not see HYPRLAND_CONFIG since this runs the
      # unwrapped binary, so both are passed explicitly.
      drv.installPhase = ''
        runHook preInstall

        HYPRLAND_CONFIG=${config.constructFiles.generatedConfig.path} \
          XDG_RUNTIME_DIR=$(mktemp -d) \
          HOME=$(mktemp -d) \
          ${lib.getExe config.package} --verify-config

        runHook postInstall
      '';

      meta.platforms = lib.platforms.linux;
    };
  };

  flake.nixosModules.feature-hyprland-m = { pkgs, ... }: {
    programs.hyprland = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.hyprland-m;
    };
  };
}
