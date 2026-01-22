{ config, pkgs, ... }:

{
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
      font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";
      logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
      theme = "bgrt";
    };
  };

  console = {
    colors = [
      "2f3136"
      "7f0000"
      "007f00"
      "666655"
      "555a66"
      "665566"
      "556666"
      "ffffff"
      "4f5258"
      "ff0000"
      "00ff00"
      "aaaa88"
      "888fa6"
      "aa88aa"
      "88aaaa"
      "e6e6e6"
    ];
    earlySetup = true;
    keyMap = "us-acentos";
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    android-tools
    fastfetch
    ffmpeg
    git
    gnupg
    lm_sensors
    neovim
    nixpkgs-fmt
    p7zip
    scrcpy
    v4l-utils
    wl-clipboard
    zsh-fzf-tab
  ];

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

  hardware = {
    alsa.enablePersistence = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        gst_all_1.gst-vaapi
        libva
        libva-vdpau-driver
        libvdpau-va-gl
        libvpx
        mesa
      ];
      extraPackages32 = with pkgs.driversi686Linux; [
        libva-vdpau-driver
        libvdpau-va-gl
        mesa
      ];
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
    inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-mozc
        ];
        waylandFrontend = true;
      };
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
    appimage.package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [
        pkgs.python312
      ];
    };

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
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
    };

    desktopManager.plasma6.enable = true;

    displayManager.sddm.enable = true;

    flatpak.enable = true;

    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
    };

    printing.enable = true;
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

  systemd.services = {
    fix-suspend-gpp0 = {
      description = "Disable GPP0 ACPI wakeup";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo GPP0 > /proc/acpi/wakeup'";
      };
    };

    flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };

  time.timeZone = "Europe/Paris";

  users.users.m = {
    description = "M";
    extraGroups = [ "networkmanager" "wheel" ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}
