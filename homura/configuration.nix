{ config, pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_hardened;
    kernelParams = [ "quiet" "random.trust_cpu=off" "slub_debug=FZ" ];
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;
  };

  console.keyMap = "us-acentos";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    fastfetch
    git
    lm_sensors
    neovim
    p7zip
    zsh-fzf-tab
  ];

  imports = [ ./hardware-configuration.nix ];

  networking = {
    hostName = "homura";
    networkmanager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    zsh = {
      autosuggestions.enable = true;
      enable = true;
      enableCompletion = true;

      interactiveShellInit = ''
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      '';

      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };

      shellAliases = {
        cln = "sudo nix-collect-garbage -d && sudo nix-store --gc && sudo nix-store --optimise && sudo nixos-rebuild boot";
        ff  = "fastfetch";
        la  = "ls -a";
        ll  = "ls -l";
        lla = "ls -la";
        upd = "sudo nixos-rebuild switch && sudo nix-channel --update && sudo nixos-rebuild switch --upgrade";
      };

      syntaxHighlighting.enable = true;
    };
  };

  services = {
    openssh.enable = true;
    xserver.xkb = {
      layout = "us";
      variant = "intl";
    };
  };

  system.stateVersion = "25.05";

  time.timeZone = "Europe/Paris";

  users.users.m = {
    description = "M";
    extraGroups = [ "networkmanager" "wheel" ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  virtualisation.docker = {
    daemon.settings = {
      default-address-pools = [
        {
          base = "192.168.145.0/8";
          size = 16;
        }
      ];
      dns = [ "9.9.9.9" ];
      storage-driver = "overlay2";
    };
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
