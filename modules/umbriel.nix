{ pkgs, ... }:

{
  environment = {
    etc."xdg/umbriel/config.toml".text = ''
      [general]
      mod_key = "Super"

      autostart = [
        "noctalia",
        '''
        out=$(wlr-randr | grep -i Panasonic | awk '{print $1}' | head -n1)
        if [ -n "$out" ]; then
          wl-gammactl -g 1.6
        fi
        ''',
      ]

      [keybinds]
      "Mod+Return" = "spawn:alacritty"
    '';
    systemPackages = with pkgs; [
      alacritty
      noctalia
      wl-gammactl
      wlr-randr
    ];
  };

  programs.umbriel.enable = true;
}
