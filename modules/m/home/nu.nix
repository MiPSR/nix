{ pkgs, ... }:

{
  programs.nushell = {
    enable = true;

    extraConfig = ''
      def lla [...args] { ls -la ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
      def la  [...args] { ls -a  ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
      def ll  [...args] { ls -l  ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
      def l   [...args] { ls     ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }

      $env.config.show_banner = false

      print $"Hello (whoami), this is ($nu.current-exe | path basename) on (^tty | complete | get stdout | str trim) running on (sys host | get hostname)"

      def cln [] {
        sudo nix-collect-garbage -d
        sudo nix-store --optimise
      }

      def nb [] { sudo nixos-rebuild boot --flake $"/home/(if 'SUDO_USER' in $env { $env.SUDO_USER } else { whoami })/code/nix" }

      def nf [] {
        cd $"/home/(if 'SUDO_USER' in $env { $env.SUDO_USER } else { whoami })/code/nix"
        sudo nix flake update
      }

      def ns [] { sudo nixos-rebuild switch --flake $"/home/(if 'SUDO_USER' in $env { $env.SUDO_USER } else { whoami })/code/nix" }

      def nt [] { sudo nixos-rebuild test --flake $"/home/(if 'SUDO_USER' in $env { $env.SUDO_USER } else { whoami })/code/nix" }

      if ((^tty | complete).exit_code == 0) and (((^tty | complete).stdout | str trim) =~ '^/dev/tty[0-9]+$') and ('TMUX' not-in $env) {
        tmux new-session
      }
    '';

    shellAliases = {
      ff = "fastfetch";
      fix-audio = "systemctl --user restart pipewire pipewire-pulse";
      hx = "hx";
    };
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
}
