{
  hostname,
  lib,
  profile,
  ...
}:

let
  hostShaded = ./m/shaded/${hostname}.nix;
in
{
  home-manager.users.m = {
    imports = [
      ./m/home
    ]
    ++ lib.optionals (profile == "laptop") [ ./m/home/laptop.nix ]
    ++ lib.optional (builtins.pathExists hostShaded) hostShaded;
  };

  imports = [ ./m/system.nix ];
}
