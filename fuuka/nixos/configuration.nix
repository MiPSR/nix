{ config, pkgs, ... }:

{
	boot = {
		kernelPackages = pkgs.linuxPackages_6_1;
	};

	imports = [
		./common.nix
		./desktop.nix
		./fix_b550.nix
		./hardware-configuration.nix
	];

	networking = {
		hostName = "fuuka";
	};

	system.stateVersion = "25.11";

	users.users.m = {
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [
			alvr
			chromium
			krita
			steam
		];
	};
}
