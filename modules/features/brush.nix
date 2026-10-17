{ ... }: {
  flake.nixosModules.feature-brush = { ... }: {
    environment.etc = {
      # Interactive, non-login shells.
      "bash.bashrc".text = ''
        if [ -n "$BRUSH_VERSION" ] && [ -r /etc/brushrc ]; then
          . /etc/brushrc
        fi
      '';

      # Login shells.
      "profile.local".text = ''
        if [ -n "$BRUSH_VERSION" ] && [ -r /etc/brushrc ]; then
          . /etc/brushrc
        fi
      '';

      # System-wide bruSH configuration, sourced from /etc/profile.local
      # (login shells) and /etc/bash.bashrc (interactive non-login shells).
      "brushrc".text = ''
        alias ff='fastfetch'
        alias l='ls'
        alias la='ls -a'
        alias ll='ls -l'
        alias lla='ls -la'

        fix-audio() {
          systemctl --user restart pipewire pipewire-pulse
        }

        cln() (
          sudo nix-collect-garbage -d
          sudo nix-store --optimise
        )

        __flake() {
          printf '/home/%s/code/nix' "''${SUDO_USER:-$(id -un)}"
        }

        nb() ( sudo nixos-rebuild boot   --flake "$(__flake)" )
        nf() ( cd "$(__flake)" && nix flake update )
        ns() ( sudo nixos-rebuild switch --flake "$(__flake)" )
        nt() ( sudo nixos-rebuild test   --flake "$(__flake)" )

        if [ -n "$PS1" ] && command -v starship >/dev/null 2>&1; then
          eval "$(starship init bash)"
        fi

        printf 'Hello %s, this is %s on %s running on %s\n' \
          "$(id -un)" "''${0##*/}" "$(tty 2>/dev/null)" "$(hostname)"

        case "$(tty 2>/dev/null)" in
          /dev/tty[0-9]*)
            if [ -z "$TMUX" ]; then
              exec tmux new-session
            fi
            ;;
        esac
      '';
    };
  };
}
