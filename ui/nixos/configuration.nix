{ config, pkgs, ... }:

{
	boot = {
		kernelPackages = pkgs.linuxPackages_zen;
	};

	imports = [
		./common.nix
		./desktop.nix
		./fix_b550.nix
		./hardware-configuration.nix
	];

	networking = {
		hostName = "ui";
	};

	programs = {
		appimage.enable = true;
		appimage.binfmt = true;
		appimage.package = pkgs.appimage-run.override {
			extraPkgs = pkgs: [
				pkgs.python312
			];
		};
	};

	services.flatpak.enable = true;

	system = {
		stateVersion = "25.11";
	};

	systemd.services.flatpak-repo = {
		wantedBy = [ "multi-user.target" ];
		path = [ pkgs.flatpak ];
		script = ''
			flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
		'';
	};

	users.users.m = {
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [
			chromium
			gnome-solanum
			google-chrome
			kdePackages.kdenlive
			krita
			microsoft-edge
			mpc-qt
			pixelorama
			protonup-qt
			prismlauncher
			signal-desktop-bin
			steam
			thunderbird-esr-bin
			transmission_4-qt6
			unityhub
			wivrn
		];
	};
}
