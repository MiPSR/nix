{ config, pkgs, ... }:

{
	boot = {
		kernelPackages = pkgs.linuxPackages_6_1;
	};

	environment.plasma6.excludePackages = with pkgs.kdePackages; [
		discover
	];

	imports = [
		./common.nix
		./desktop.nix
		./fix_b550.nix
		./hardware-configuration.nix
	];

	networking = {
		hostName = "fuuka";
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

	system.stateVersion = "25.11";

	users.users.m = {
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [
			chromium
			krita
			steam
			wivrn
		];
	};
}
