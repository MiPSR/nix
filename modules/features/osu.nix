{ ... }: {
  flake.nixosModules.feature-osu = { pkgs, lib, ... }: let
    tosuVersion = "4.26.2";
    roxysuVersion = "0.1.18";

    tosu = pkgs.stdenv.mkDerivation {
      pname = "tosu";
      version = tosuVersion;
      src = pkgs.fetchurl {
        url = "https://github.com/tosuapp/tosu/releases/download/v${tosuVersion}/tosu-linux-v${tosuVersion}.zip";
        hash = "sha256-buVpYhcd2jYOYqvtb6UoWcxkUAzzvbtFGnGxJcxFKGc=";
      };
      nativeBuildInputs = [ pkgs.unzip ];
      dontConfigure = true;
      dontBuild = true;
      dontPatchELF = true;
      dontStrip = true;
      unpackPhase = ''
        runHook preUnpack
        unzip -o "$src" -d .
        runHook postUnpack
      '';
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        install -Dm755 tosu $out/bin/tosu
        runHook postInstall
      '';
      meta = {
        description = "osu! memory reader and PP counter provider";
        homepage = "https://github.com/tosuapp/tosu";
        license = lib.licenses.lgpl3Only;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        mainProgram = "tosu";
        platforms = [ "x86_64-linux" ];
      };
    };

    roxysuNativeLibs = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      icu
    ];

    roxysu = pkgs.stdenv.mkDerivation {
      pname = "roxysu";
      version = roxysuVersion;
      src = pkgs.fetchurl {
        url = "https://github.com/Yon-Luc/Roxysu/releases/download/v${roxysuVersion}/Roxysu-${roxysuVersion}-linux-x64-resources.tar.gz";
        hash = "sha256-S8qOa38bR+TG5cpKq//huXGgNHRZVcJ5VwK4n1u8wHs=";
      };
      nativeBuildInputs = [
        pkgs.autoPatchelfHook
        pkgs.makeWrapper
        pkgs.copyDesktopItems
      ];
      buildInputs = roxysuNativeLibs;
      dontStrip = true;
      installPhase = ''
        runHook preInstall
        appdir="$out/lib/roxysu"
        resources="$appdir/resources"
        mkdir -p "$appdir" "$out/share/icons/hicolor/512x512/apps"
        cp -a . "$appdir/"
        tar -xzf "$resources/realm-reader.tgz" -C "$resources"
        rm -f "$resources/realm-reader.tgz"
        cp "$resources/public/icons/icon-512.png" "$out/share/icons/hicolor/512x512/apps/roxysu.png"
        makeWrapper ${pkgs.electron_42}/bin/electron "$out/bin/roxysu" \
          --add-flags "$appdir" \
          --set ELECTRON_SKIP_BINARY_DOWNLOAD 1 \
          --set ROXYSU_RESOURCES "$resources" \
          --set-default HUB_URL "https://roxysu-api.yonx.app" \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath roxysuNativeLibs}
        runHook postInstall
      '';
      desktopItems = [
        (pkgs.makeDesktopItem {
          name = "roxysu";
          desktopName = "Roxysu";
          genericName = "osu! Practice Companion";
          comment = "Practice companion for osu!";
          exec = "roxysu";
          icon = "roxysu";
          categories = [
            "Game"
            "Utility"
          ];
          terminal = false;
          startupNotify = true;
          startupWMClass = "Roxysu";
        })
      ];
      meta = {
        description = "osu! practice companion";
        homepage = "https://github.com/Yon-Luc/Roxysu";
        license = lib.licenses.mit;
        platforms = [ "x86_64-linux" ];
        mainProgram = "roxysu";
      };
    };

  in {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        icu
        stdenv.cc.cc.lib
      ];
    };

    environment.systemPackages = [
      pkgs.gamescope
      pkgs.osu-lazer-bin
      roxysu
    ];

    security.wrappers.tosu = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_ptrace=eip";
      source = "${tosu}/bin/tosu";
    };
  };
}