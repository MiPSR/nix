{ hostname, lib, pkgs, ... }:

let
  sharedFile = ./niri/shared.kdl;
  execFile = ./niri/exec/${hostname}.kdl;
  outputsFile = ./niri/outputs/${hostname}.kdl;
  palette = import ../../../palette.nix;

  modPrefix = "Mod+";

  sharedText = builtins.replaceStrings
    [ "@border-active@" "@border-inactive@" "@border-urgent@" ]
    [ palette.brightBlue palette.blue palette.red ]
    (builtins.readFile sharedFile);

  bindsText = "binds {\n" + builtins.replaceStrings [ "Mod+" ] [ modPrefix ] (
    lib.concatMapStrings builtins.readFile [
      ./niri/binds/shared.kdl
      ./niri/binds/${hostname}.kdl
    ]
  ) + "\n}\n";

  configText = ''
${sharedText}
${bindsText}
${builtins.readFile execFile}
${builtins.readFile outputsFile}
  '';

  configFile = pkgs.writeText "niri-config.kdl" configText;
in
{
  home.activation.removeLegacyHyprland = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    		rm -rf "''${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
    	'';

  xdg.configFile."niri/config.kdl" = {
    source = pkgs.runCommand "niri-config.kdl" { } ''
      ${pkgs.niri}/bin/niri validate -c ${configFile}
      cp ${configFile} $out
    '';
    force = true;
  };
}
