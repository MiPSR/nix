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
			logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png";
			theme = "bgrt";
		};
	};

	console = {
		font = "ter-v14b";
		packages = [ pkgs.terminus_font ];
	};

	environment = {
		sessionVariables.NIXOS_OZONE_WL = "1";

		systemPackages = with pkgs; [
			fastfetch
			git
			gnupg
			lm_sensors
			neovim
			nixpkgs-fmt
			p7zip
			zsh-fzf-tab
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
				upd = "sudo nixos-rebuild switch && sudo nix-channel --update && sudo nixos-rebuild switch --upgrade";
			};

			syntaxHighlighting.enable = true;
		};
	};

	time.timeZone = "Europe/Paris";

	users.users.m = {
		description = "M";
		home = "/home/m/";
		isNormalUser = true;
		shell = pkgs.zsh;
	};
}
