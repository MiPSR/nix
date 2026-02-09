{ config, pkgs, ... }:

{
	environment = {
		systemPackages = with pkgs; [
			alsa-utils
			android-tools
			ffmpeg
			scrcpy
			v4l-utils
			wl-clipboard
		];
	};

	fonts = {
		fontDir.enable = true;

		fontconfig = {
			defaultFonts = {
				emoji = [ "Noto Color Emoji" ];
				monospace = [ "IBM Plex Mono" ];
				sansSerif = [ "IBM Plex Sans" "Source Han Sans" ];
				serif = [ "IBM Plex Serif" "Source Han Serif" ];
			};
			enable = true;
		};

		packages = with pkgs; [
			ibm-plex
			noto-fonts
			noto-fonts-cjk-sans
			noto-fonts-cjk-serif
			noto-fonts-color-emoji
			source-han-sans
			source-han-serif
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
	};

	i18n = {
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

	programs.zsh = {
		interactiveShellInit = ''
			cam() { scrcpy --camera-size=1280x720 --max-fps=30 --no-audio --no-playback --render-driver=vulkan --v4l2-sink=/dev/video0 --video-codec=h265 --video-encoder=OMX.qcom.video.encoder.hevc --video-source=camera --camera-id="$1"; }
			'';

		shellAliases = {
			fix-audio = "systemctl --user restart pipewire pipewire-pulse";
			phn = "scrcpy --max-fps=60 --stay-awake --turn-screen-off --render-driver=vulkan --video-codec=h264 --video-encoder=OMX.qcom.video.encoder.avc";
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

		pipewire = {
			alsa.enable = true;
			alsa.support32Bit = true;
			enable = true;
			jack.enable = true;
			pulse.enable = true;
		};

		printing.enable = true;
	};

	systemd.user.tmpfiles.rules = [
		"L+ %h/.local/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
	];
}
