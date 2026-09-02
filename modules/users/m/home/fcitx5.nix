{ hostname, ... }:

let
  palette = import ../../../palette.nix;
in

{
  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    		[FcitxClassicUI]
    		Theme=m-palette
    	'';

  xdg.configFile."fcitx5/profile".text = ''
    		[Groups/0]
    		Name=Default
    		Default Layout=us
    		DefaultIM=keyboard-us

    		[Groups/0/Items/0]
    		Name=keyboard-us
    		Local=us

    		[Groups/0/Items/1]
    		Name=keyboard-ru
    		Local=ru

    		[Groups/0/Items/2]
    		Name=mozc
    		Local=ja

    		[GroupOrder]
    		0=Default
    	'';

  xdg.dataFile."fcitx5/themes/m-palette/theme.conf".text = ''
    		[Metadata]
    		Name=m-palette
    		Version=1
    		Description=m-palette theme for fcitx5 classic UI
    		ScaleWithDPI=True

    		[InputPanel]
    		Font=Roboto 10
    		NormalColor=${palette.light}
    		CandidateLabelColor=${palette.dark}
    		HighlightColor=${palette.brightBlue}
    		HighlightBackgroundColor=${palette.blue}55
    		HighlightCandidateColor=${palette.black}

    		[InputPanel/Background]
    		Color=${palette.black}ee
    		BorderColor=${palette.dark}
    		BorderWidth=1

    		[InputPanel/Highlight]
    		Color=${palette.brightBlue}

    		[Menu]
    		Font=Roboto 10
    		NormalColor=${palette.light}
    		HighlightCandidateColor=${palette.black}

    		[Menu/Background]
    		Color=${palette.black}ee
    		BorderColor=${palette.dark}
    		BorderWidth=1

    		[Menu/Separator]
    		Color=${palette.blue}55
    	'';
}
