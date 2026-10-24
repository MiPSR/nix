{ ... }: {
  flake.nixosModules.feature-fish = { ... }: {
    environment = {
      etc."xdg/starship.toml".text = ''
        add_newline = false

        format = '$username$hostname$directory$git_branch$git_status$cmd_duration$line_break$character'

        [character]
        error_symbol = '[>](bold red)'
        success_symbol = '[>](bold green)'

        [git_branch]
        format = '[\[ $symbol$branch \]]($style)'

        [git_status]
        format = '[\[ $all_status$ahead_behind \]]($style)'

        [hostname]
        ssh_only = false
        format = '[\[ $hostname \]]($style)'

        [username]
        show_always = true
        format = '[\[ $user \]]($style)'
      '';

      variables.STARSHIP_CONFIG = "/etc/xdg/starship.toml";
    };

    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        set -gx STARSHIP_CONFIG /etc/xdg/starship.toml
        set -g fish_greeting

        printf 'Hello %s, this is %s on %s running on %s\n' \
          (id -un) (basename (status fish-path)) (tty 2>/dev/null) (hostname)
      '';

      loginShellInit = ''
        if status is-interactive
          switch (tty 2>/dev/null)
            case '/dev/tty*'
              if not set -q TMUX
                exec tmux new-session
              end
          end
        end
      '';

      promptInit = ''
        if command -v starship >/dev/null
          starship init fish | source
        end
      '';

      shellAliases = {
        cln = "sudo nix-collect-garbage -d && sudo nix-store --optimise";
        ff = "fastfetch";
        fix-audio = "systemctl --user restart pipewire pipewire-pulse";
        l = "ls";
        la = "ls -a";
        ll = "ls -l";
        lla = "ls -la";
        nb = "fish -c 'cd /home/m/code/nix && sudo nixos-rebuild boot --flake'";
        nf = "fish -c 'cd /home/m/code/nix && nix flake update'";
        ns = "fish -c 'cd /home/m/code/nix && sudo nixos-rebuild switch --flake'";
        nt = "fish -c 'cd /home/m/code/nix && sudo nixos-rebuild test --flake'";
      };
    };
  };
}
