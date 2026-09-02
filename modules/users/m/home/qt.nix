{
  hostname,
  lib,
  ...
}:

let
  palette = import ../../../palette.nix;

  hexDigit =
    c:
    builtins.getAttr c {
      "0" = 0;
      "1" = 1;
      "2" = 2;
      "3" = 3;
      "4" = 4;
      "5" = 5;
      "6" = 6;
      "7" = 7;
      "8" = 8;
      "9" = 9;
      "a" = 10;
      "b" = 11;
      "c" = 12;
      "d" = 13;
      "e" = 14;
      "f" = 15;
    };

  channels =
    hex:
    map (i: hexDigit (builtins.substring i 1 hex) * 16 + hexDigit (builtins.substring (i + 1) 1 hex)) [
      1
      3
      5
    ];

  rgb = hex: lib.concatStringsSep ", " (map toString (channels hex));

  mix =
    t: base: toward:
    lib.concatStringsSep ", " (
      map
        (
          i:
          toString (
            builtins.floor (
              builtins.elemAt (channels base) i
              + (builtins.elemAt (channels toward) i - builtins.elemAt (channels base) i) * t
            )
          )
        )
        [
          0
          1
          2
        ]
    );

  elevated = mix 0.06 palette.black palette.light;

  colorSection = name: bg: altBg: ''
    		[Colors:${name}]
    		BackgroundAlternate=${altBg}
    		BackgroundNormal=${bg}
    		DecorationFocus=${rgb palette.brightBlue}
    		DecorationHover=${rgb palette.brightBlue}
    		ForegroundActive=${rgb palette.white}
    		ForegroundInactive=${rgb palette.dark}
    		ForegroundLink=${rgb palette.brightBlue}
    		ForegroundNegative=${rgb palette.brightRed}
    		ForegroundNeutral=${rgb palette.brightYellow}
    		ForegroundNormal=${rgb palette.light}
    		ForegroundPositive=${rgb palette.brightGreen}
    		ForegroundVisited=${rgb palette.brightMagenta}
    	'';

  schemeName = "m-palette";
in

{
  qt = {
    enable = true;

    platformTheme.name = "qt6ct";

    qt6ctSettings.Appearance = {
      color_scheme_path = "/home/m/.local/share/color-schemes/${schemeName}.colors";
      custom_palette = false;
      icon_theme = "Papirus-Dark";
      standard_palette = false;
      style = "Fusion";
    };

    style.name = "Fusion";
  };

  xdg.configFile."kdeglobals".text = ''
    		[General]
    		ColorScheme=${schemeName}
    		Name=${schemeName}
    	'';

  xdg.dataFile."color-schemes/${schemeName}.colors".text = lib.concatStringsSep "\n\n" [
    ''
      			[ColorEffects:Disabled]
      			Color=${rgb palette.black}
      			ColorAmount=0.3
      			ColorEffect=2
      			ContrastAmount=0.1
      			ContrastEffect=0
      			IntensityAmount=-1
      			IntensityEffect=0
      		''
    ''
      			[ColorEffects:Inactive]
      			ChangeSelectionColor=true
      			Color=${rgb palette.black}
      			ColorAmount=0.5
      			ColorEffect=3
      			ContrastAmount=0
      			ContrastEffect=0
      			Enable=true
      			IntensityAmount=0
      			IntensityEffect=0
      		''
    (colorSection "Button" elevated elevated)
    (colorSection "Complementary" elevated elevated)
    (colorSection "Header" elevated elevated)
    ''
      			[Colors:Selection]
      			BackgroundAlternate=${rgb palette.brightBlue}
      			BackgroundNormal=${rgb palette.brightBlue}
      			DecorationFocus=${rgb palette.black}
      			DecorationHover=${rgb palette.black}
      			ForegroundActive=${rgb palette.black}
      			ForegroundInactive=${rgb palette.blue}
      			ForegroundLink=${rgb palette.brightBlue}
      			ForegroundNegative=${rgb palette.brightRed}
      			ForegroundNeutral=${rgb palette.brightYellow}
      			ForegroundNormal=${rgb palette.black}
      			ForegroundPositive=${rgb palette.brightGreen}
      			ForegroundVisited=${rgb palette.brightMagenta}
      		''
    (colorSection "Tooltip" elevated elevated)
    (colorSection "View" (rgb palette.black) elevated)
    (colorSection "Window" (rgb palette.black) elevated)
    ''
      			[General]
      			ColorScheme=${schemeName}
      			Name=${schemeName}
      			accentActiveTitlebar=false
      			shadeSortColumn=true
      		''
    ''
      			[KDE]
      			contrast=4
      		''
    ''
      			[WM]
      			activeBackground=${rgb palette.black}
      			activeBlend=${rgb palette.light}
      			activeForeground=${rgb palette.light}
      			inactiveBackground=${rgb palette.black}
      			inactiveBlend=${rgb palette.dark}
      			inactiveForeground=${rgb palette.dark}
      		''
  ];
}
