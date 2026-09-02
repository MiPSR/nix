# Per-host main color for user m's home, layered on top of the generic
# system palette (modules/palette.nix), which it leaves untouched.
#
# `accent`/`accentBright` are the low/high intensity main hue of the
# machine. `papirusAccent` is the matching catppuccin-papirus-folders
# accent name; there is no magenta upstream, mauve is the closest to
# hue 300.
#
# Usage: `import ./m-palette.nix hostname`.

hostname:

let
  base = import ../../../palette.nix;

  mains = {
    roxy = {
      accent = base.blue;
      accentBright = base.brightBlue;
      papirusAccent = "blue";
    };
  };
in
base // mains.${hostname}
