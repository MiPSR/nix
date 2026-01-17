{ config, pkgs, ... }:

{
  boot = {
    consoleLogLevel = 3;

    initrd = {
      systemd.enable = true;
      verbose = false;
    };

    kernelModules = [
      "v4l2loopback"
    ];

    kernelPackages = pkgs.linuxPackages_zen;

    kernelParams = [
      "boot.shell_on_fail"
      "intremap=on"
      "quiet"
      "rd.systemd.show_status=auto"
      "splash"
      "udev.log_priority=3"
    ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        consoleMode = "max";
        enable = true;
      };
    };

    plymouth = {
      enable = true;
      font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";
      logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
      theme = "bgrt";
    };
  };

  console = {
      colors = [
        "2f3136" "7f0000" "007f00" "666655"
        "555a66" "665566" "556666" "ffffff"
        "4f5258" "ff0000" "00ff00" "aaaa88"
        "888fa6" "aa88aa" "88aaaa" "e6e6e6"
      ];
      earlySetup = true;
      keyMap = "us-acentos";
    };

  environment.systemPackages = with pkgs; [
    alsa-utils
    fastfetch
    git
    ibus
    ibus-engines.anthy
    ibus-engines.m17n
    ibus-engines.mozc
    kdePackages.partitionmanager
    lm_sensors
    neovim
    p7zip
    zsh-fzf-tab
  ];

  fonts = {
    fontDir.enable = true;

    fontconfig = {
      defaultFonts = {
        emoji      = [ "Twemoji Color Font" ];
        monospace = [ "IBM Plex Mono" ];
        sansSerif = [ "IBM Plex Sans" ];
        serif     = [ "Source Han Sans JP" ];
      };
      enable = true;
    };

    packages = with pkgs; [
      ibm-plex
      source-han-sans
      twemoji-color-font
    ];
  };

  hardware = {
    alsa.enablePersistence = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ libva libva-vdpau-driver mesa ];
      extraPackages32 = with pkgs.driversi686Linux; [ mesa ];
    };

    steam-hardware.enable = true;
  };

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


  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "ui";
    networkmanager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    appimage.enable = true;
    appimage.binfmt = true;
    appimage.package = pkgs.appimage-run.override { extraPkgs = pkgs: [
      pkgs.python312
    ]; };
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

  security.rtkit.enable = true;

  services = {
    desktopManager.plasma6.enable = true;

    displayManager.sddm.enable = true;

    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
    };

    printing.enable = true;

    wivrn.enable = true;
  };

  system = {
    stateVersion = "25.11";

    userActivationScripts = {
      linktosharedfolder.text = ''
        if [[ ! -h "$HOME/.local/share/fonts" ]]; then
          ln -s "/run/current-system/sw/share/X11/fonts" "$HOME/.local/share/fonts"
        fi
      '';
    };
  };

  systemd.services.fix-suspend-gpp0 = {
    description = "Disable GPP0 ACPI wakeup";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo GPP0 > /proc/acpi/wakeup'";
    };
  };

  time.timeZone = "Europe/Paris";

  users.users.m = {
    description = "M";
    extraGroups = [ "networkmanager" "wheel" ];
    isNormalUser = true;
    packages = with pkgs; [
      android-tools
      google-chrome
      heroic
      kdePackages.kate
      librewolf
      microsoft-edge
      mpc-qt
      obs-studio
      osu-lazer-bin
      scrcpy
      steam
      thunderbird-bin
      vesktop
      wayvr
    ];
    shell = pkgs.zsh;
  };
}
