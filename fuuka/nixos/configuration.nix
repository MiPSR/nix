{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    consoleLogLevel = 3;

    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Webcam"
    '';

    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

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
      font = "${pkgs.ibm-plex}/share/fonts/opentype/IBMPlexMono-Regular.otf";
      logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png";
      theme = "bgrt";
    };
  };

  console.keyMap = "us-acentos";

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      alsa-utils
      android-tools
      fastfetch
      ffmpeg
      git
      neovim
      nixpkgs-fmt
      p7zip
      scrcpy
      v4l-utils
      zsh-fzf-tab
    ];
  };

  fonts = {
    fontDir.enable = true;

    fontconfig = {
      defaultFonts = {
        emoji = [ "Twemoji Color Font" ];
        monospace = [ "IBM Plex Mono" ];
        sansSerif = [ "IBM Plex Sans" "Source Han Sans" ];
        serif = [ "IBM Plex Serif" "Source Han Serif" ];
      };
      enable = true;
    };

    packages = with pkgs; [
      ibm-plex
      source-han-sans
      source-han-serif
      twemoji-color-font
    ];
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

  networking = {
    hostName = "fuuka";
    networkmanager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    zsh = {
      autosuggestions.enable = true;
      enable = true;
      enableCompletion = true;

      interactiveShellInit = ''
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        cam() { scrcpy --camera-size=1280x720 --max-fps=30 --no-audio --no-playback --render-driver=vulkan --v4l2-sink=/dev/video0 --video-codec=h265 --video-encoder=OMX.qcom.video.encoder.hevc --video-source=camera --camera-id="$1"; }
      '';

      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };

      shellAliases = {
        cln = "sudo nix-collect-garbage -d && sudo nix-store --gc && sudo nix-store --optimise && sudo nixos-rebuild boot";
        ff = "fastfetch";
        la = "ls -a";
        ll = "ls -l";
        lla = "ls -la";
        phn = "scrcpy --max-fps=60 --stay-awake --turn-screen-off --render-driver=vulkan --video-codec=h264 --video-encoder=OMX.qcom.video.encoder.avc";
        upd = "sudo nixos-rebuild switch && sudo nix-channel --update && sudo nixos-rebuild switch --upgrade";
      };

      syntaxHighlighting.enable = true;
    };
  };

  security.rtkit.enable = true;

  services = {
    displayManager.defaultSession = "none+i3";

    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
    };

    printing.enable = true;

    xserver = {
      desktopManager = {
        xterm.enable = false;
      };

      displayManager.lightdm.enable = true;

      enable = true;

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-rounded;
        extraPackages = with pkgs; [
          i3lock
          i3status-rust
          rofi
          xkb-switch-i3
        ];
      };

      xkb = {
        layout = "us";
        variant = "intl";
      };
    };
  };

  system.stateVersion = "25.11";

  systemd.services = {
    fix-suspend-gpp0 = {
      description = "Disable GPP0 ACPI wakeup";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo GPP0 > /proc/acpi/wakeup'";
      };
    };
  };

  time.timeZone = "Europe/Paris";

  users.users.m = {
    description = "M";
    extraGroups = [ "networkmanager" "wheel" ];
    isNormalUser = true;
    packages = with pkgs; [
      chromium
      kitty
    ];
    shell = pkgs.zsh;
  };

  xdg.portal.config = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = true;
  };
}
