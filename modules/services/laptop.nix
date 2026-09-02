{
  services = {
    displayManager = {
      defaultSession = "niri";
      gdm.enable = true;
    };

    gnome.gnome-keyring.enable = true;

    gvfs.enable = true;

    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      jack.enable = true;
      pulse.enable = true;
    };

    power-profiles-daemon.enable = true;

    printing.enable = true;

    udev.extraRules = ''
      				KERNEL=="hidraw*", MODE="0666"
      		'';

    udisks2.enable = true;

    upower.enable = true;
  };
}
