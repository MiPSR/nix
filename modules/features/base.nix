{ ... }: {
  flake.nixosModules.feature-base = { pkgs, ... }: {
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
      git
      nixfmt
      p7zip
    ];

    hardware.enableRedistributableFirmware = true;

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
      firewall.enable = true;
      networkmanager.enable = true;
    };

    nix.settings.experimental-features = [
      "flakes"
      "nix-command"
    ];

    nixpkgs.config.allowUnfree = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    time.timeZone = "Europe/Paris";

    zramSwap = {
      enable = true;
      memoryPercent = 100;
    };
  };
}
