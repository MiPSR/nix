{ pkgs, ... }:

{
  boot = {
    consoleLogLevel = 3;

    initrd = {
      systemd.enable = true;
      verbose = false;
    };

    kernel.sysctl."vm.swappiness" = 190;

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
      logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png";
      theme = "bgrt";
    };

    tmp = {
      tmpfsSize = "50%";
      useTmpfs = true;
    };
  };

  environment.systemPackages = with pkgs; [
    btop
    fastfetch
    nixfmt
    p7zip
  ];

  hardware.opentabletdriver.enable = true;

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
      enable = true;
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-mozc
        ];
        waylandFrontend = true;
      };
      type = "fcitx5";
    };
  };

  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];

  nixpkgs.config.allowUnfree = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  security.rtkit.enable = true;

  services = {
    displayManager.noctalia-greeter.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
    };
    udisks2.enable = true;
    xserver.enable = false;
  };

  time.timeZone = "Europe/Paris";

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}
