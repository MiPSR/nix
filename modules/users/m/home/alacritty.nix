{ hostname, ... }:

let
  palette = import ../../../palette.nix;
in

{
  xdg.configFile."alacritty/alacritty.toml" = {
    force = true;
    text = ''
      			[colors.bright]
      			black = "${palette.dark}"
      			blue = "${palette.brightBlue}"
      			cyan = "${palette.brightTeal}"
      			green = "${palette.brightGreen}"
      			magenta = "${palette.brightMagenta}"
      			red = "${palette.brightRed}"
      			white = "${palette.white}"
      			yellow = "${palette.brightYellow}"

      			[colors.cursor]
      			cursor = "${palette.brightBlue}"
      			text = "${palette.black}"

      			[colors.normal]
      			black = "${palette.black}"
      			blue = "${palette.blue}"
      			cyan = "${palette.teal}"
      			green = "${palette.green}"
      			magenta = "${palette.magenta}"
      			red = "${palette.red}"
      			white = "${palette.light}"
      			yellow = "${palette.yellow}"

      			[colors.primary]
      			background = "${palette.black}"
      			foreground = "${palette.light}"

      			[font]
      			size = 12.0

      			[font.normal]
      			family = "RobotoMono Nerd Font"

      			[window.padding]
      			x = 8
      			y = 8
      		'';
  };
}
