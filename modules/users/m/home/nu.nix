{ pkgs, ... }:

{
  programs.nushell = {
    enable = true;

    extraConfig = ''
            			$env.config.show_banner = false

            			def cln [] {
            				sudo nix-collect-garbage -d
            				sudo nix-store --optimise
            			}

      			# Flake rebuilds from this repo checkout (~/code/nix).
      			def nb [] { sudo nixos-rebuild boot --flake ~/code/nix }

      			def nf [] {
      				cd ~/code/nix
      				sudo nix flake update
      			}

      			def ns [] { sudo nixos-rebuild switch --flake ~/code/nix }

      			def nt [] { sudo nixos-rebuild test --flake ~/code/nix }

            			def restart-sunshine [] {
            				pkill sunshine
            				let display = (ls /run/user/1000/wayland-* | where name !~ 'lock' | get 0.name | path basename)
            				^env WAYLAND_DISPLAY=$display XDG_SESSION_TYPE=wayland sunshine o+e>/dev/null &
            			}

            			# Auto-start tmux on raw TTYs only (no graphical session, not inside tmux).
            			let tty_info = (^tty | complete)
            			if ($tty_info.exit_code == 0) and (($tty_info.stdout | str trim) =~ '^/dev/tty[0-9]+$') and ('TMUX' not-in $env) {
            				tmux new-session
            			}
            		'';

    shellAliases = {
      ff = "fastfetch";
      fix-audio = "systemctl --user restart pipewire pipewire-pulse";
      la = "ls -a";
      ll = "ls -l";
      lla = "ls -la";
      overdo = "sudo";
      phn = "scrcpy --max-fps=60 --stay-awake --turn-screen-off --render-driver=vulkan --video-codec=h264 --video-encoder=OMX.qcom.video.encoder.avc";
    };
  };
}
