{ ... }: {
  flake.nixosModules.host-ui-hardware = { lib, ... }: {
    boot = {
      initrd = {
        availableKernelModules = [
          "ahci"
          "nvme"
          "usbhid"
          "xhci_pci"
        ];

        luks.devices."master".device = "/dev/disk/by-uuid/b6b913ca-6cf0-4392-9da0-d46d13f6adc5";
      };

      kernelModules = [ "kvm-amd" ];
    };

    fileSystems = {
      "/" = {
        device = "/dev/mapper/master";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/AAE2-F545";
        fsType = "vfat";
        options = [
          "dmask=0077"
          "fmask=0077"
        ];
      };

      "/mnt/slave" = {
        device = "/dev/disk/by-uuid/ae6d755d-c6de-4e93-89b8-5fdecfeca252";
        fsType = "ext4";
      };
    };

    hardware.cpu.amd.updateMicrocode = true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
