{ config, pkgs, ... }:

{
	systemd.services = {
		fix-suspend-gpp0 = {
			description = "Disable GPP0 ACPI wakeup";
			serviceConfig = {
				ExecStart = "${pkgs.bash}/bin/bash -c 'echo GPP0 > /proc/acpi/wakeup'";
				Type = "oneshot";
			};
			wantedBy = [ "multi-user.target" ];
		};
	};
}
