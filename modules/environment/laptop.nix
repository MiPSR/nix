{ hostname, pkgs, ... }:

let
  palette = import ../users/m/home/m-palette.nix hostname;
in

{
  imports = [ ./default.nix ];

  environment = {
    etc = {
      "xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-application-prefer-dark-theme=true
        gtk-cursor-theme-name=Bibata-Modern-Ice
        gtk-cursor-theme-size=24
        gtk-icon-theme-name=Papirus-Dark
        gtk-theme-name=Adwaita-dark
      '';

      "xdg/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-application-prefer-dark-theme=true
        gtk-cursor-theme-name=Bibata-Modern-Ice
        gtk-cursor-theme-size=24
        gtk-icon-theme-name=Papirus-Dark
        gtk-theme-name=Adwaita-dark
      '';

      "xdg/xdg-terminals.list".text = ''
        				Alacritty.desktop
        			'';
    };

    sessionVariables = {
      GTK_THEME = "Adwaita-dark";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      TERMINAL = "alacritty";
      XCURSOR_SIZE = "24";
      XCURSOR_THEME = "Bibata-Modern-Ice";
    };

    systemPackages = with pkgs; [
      alacritty
      alsa-utils
      amberol
      android-tools
      awww
      bibata-cursors
      (catppuccin-papirus-folders.override {
        accent = palette.papirusAccent;
        flavor = "frappe";
      })
      gnome-themes-extra
      imv
      kdePackages.breeze
      kdePackages.kate
      kdePackages.kservice
      qt6Packages.qt6ct
      scrcpy
      thunar-volman
      tumbler
      wayle
      wl-clipboard
      xdg-terminal-exec
      xdg-utils
      xwayland-satellite
    ];
  };
}
