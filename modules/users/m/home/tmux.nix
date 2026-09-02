{ hostname, pkgs, ... }:

let
  palette = import ../../../palette.nix;
in

{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      			set -g default-command "${pkgs.nushell}/bin/nu"
      			set -g default-shell "${pkgs.nushell}/bin/nu"

      			set -g default-terminal "tmux-256color"
      			set -as terminal-overrides ",*:Tc"
      			set -as terminal-overrides ",*:sitm=\E[3m"

      			# Wayle-style bar: accent strip, black chips; colors from m-palette.nix.
      			set -g status-style "bg=${palette.brightBlue}"
      			set -g status-left-length 32
      			set -g status-right-length 32
      			set -g status-left "#[bg=${palette.black},fg=${palette.brightBlue},bold] #S "
      			set -g status-right "#[bg=${palette.black},fg=${palette.light}] %H:%M "

      			set -g window-status-format "#[bg=${palette.black},fg=${palette.light}]#I:#W#[bg=${palette.brightBlue}] "
      			set -g window-status-current-format "#[bg=${palette.black},fg=${palette.brightBlue},bold]#I:#W#[bg=${palette.brightBlue}] "
      			set -g window-status-separator ""
      		'';
  };
}
