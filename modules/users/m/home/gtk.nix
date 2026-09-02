{ hostname, pkgs, ... }:

let
  palette = import ./m-palette.nix hostname;
in

{
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    cursor-size = 24;
    cursor-theme = "Bibata-Modern-Ice";
    gtk-theme = "Adwaita-dark";
    icon-theme = "Papirus-Dark";
  };

  gtk = {
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    enable = true;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk3.extraCss = ''
      			@define-color theme_bg_color ${palette.black};
      			@define-color theme_fg_color ${palette.light};
      			@define-color theme_base_color ${palette.black};
      			@define-color theme_text_color ${palette.light};

      			@define-color theme_selected_bg_color ${palette.brightBlue};
      			@define-color theme_selected_fg_color ${palette.black};

      			@define-color theme_unfocused_bg_color ${palette.black};
      			@define-color theme_unfocused_fg_color ${palette.light};
      			@define-color theme_unfocused_base_color ${palette.black};
      			@define-color theme_unfocused_text_color ${palette.light};
      			@define-color theme_unfocused_selected_bg_color ${palette.blue};
      			@define-color theme_unfocused_selected_fg_color ${palette.black};

      			@define-color insensitive_bg_color ${palette.black};
      			@define-color insensitive_fg_color ${palette.dark};
      			@define-color insensitive_base_color ${palette.black};

      			@define-color borders ${palette.dark};
      			@define-color unfocused_borders ${palette.dark};

      			@define-color warning_color ${palette.brightYellow};
      			@define-color error_color ${palette.brightRed};
      			@define-color success_color ${palette.brightGreen};

      			@define-color placeholder_text_color rgba(158, 158, 158, 0.5);

      			@define-color link_color ${palette.brightBlue};
      			@define-color link_visited_color ${palette.brightMagenta};

      			@define-color wm_title ${palette.light};
      			@define-color wm_unfocused_title ${palette.dark};

      			headerbar,
      			headerbar:backdrop {
      				background: @theme_bg_color;
      			}
      		'';

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraCss = ''
      			@define-color accent_color ${palette.brightBlue};
      			@define-color accent_bg_color ${palette.brightBlue};
      			@define-color accent_fg_color ${palette.black};

      			@define-color success_color ${palette.brightGreen};
      			@define-color success_bg_color ${palette.brightGreen};
      			@define-color success_fg_color ${palette.black};

      			@define-color warning_color ${palette.brightYellow};
      			@define-color warning_bg_color ${palette.brightYellow};
      			@define-color warning_fg_color ${palette.black};

      			@define-color error_color ${palette.brightRed};
      			@define-color error_bg_color ${palette.brightRed};
      			@define-color error_fg_color ${palette.black};

      			@define-color window_bg_color ${palette.black};
      			@define-color window_fg_color ${palette.light};

      			@define-color view_bg_color ${palette.black};
      			@define-color view_fg_color ${palette.light};

      			@define-color headerbar_bg_color ${palette.black};
      			@define-color headerbar_fg_color ${palette.light};
      			@define-color headerbar_border_color ${palette.black};
      			@define-color headerbar_backdrop_color ${palette.black};
      			@define-color headerbar_shade_color rgba(158, 158, 158, 0.12);
      			@define-color headerbar_dnd_shade_color rgba(0, 0, 0, 0.32);

      			@define-color sidebar_bg_color ${palette.black};
      			@define-color sidebar_fg_color ${palette.light};
      			@define-color sidebar_backdrop_color ${palette.black};
      			@define-color sidebar_shade_color rgba(158, 158, 158, 0.12);
      			@define-color sidebar_border_color rgba(158, 158, 158, 0.12);

      			@define-color secondary_sidebar_bg_color ${palette.black};
      			@define-color secondary_sidebar_fg_color ${palette.light};
      			@define-color secondary_sidebar_backdrop_color ${palette.black};

      			@define-color card_bg_color ${palette.black};
      			@define-color card_fg_color ${palette.light};
      			@define-color card_shade_color rgba(0, 0, 0, 0.36);

      			@define-color dialog_bg_color ${palette.black};
      			@define-color dialog_fg_color ${palette.light};

      			@define-color popover_bg_color ${palette.black};
      			@define-color popover_fg_color ${palette.light};

      			@define-color thumbnail_bg_color ${palette.black};
      			@define-color thumbnail_fg_color ${palette.light};

      			@define-color shade_color rgba(0, 0, 0, 0.36);
      			@define-color scrollbar_outline_color ${palette.black};
      		'';

    iconTheme = {
      name = "Papirus-Dark";
      package = (
        pkgs.catppuccin-papirus-folders.override {
          accent = palette.papirusAccent;
          flavor = "frappe";
        }
      );
    };

    theme.name = "Adwaita-dark";
  };
}
