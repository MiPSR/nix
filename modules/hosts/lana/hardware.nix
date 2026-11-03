{ ... }: {
  flake.nixosModules.host-lana-hardware = { lib, ... }: {
    boot = {
      initrd = {
        availableKernelModules = [
          "ahci"
          "nvme"
          "usbhid"
          "xhci_pci"
        ];

        luks.devices."master".device = "/dev/disk/by-uuid/xxxx";
      };

      kernelModules = [ "kvm-amd" ];
    };

    fileSystems = {
      "/" = {
        device = "/dev/mapper/master";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/xxxx";
        fsType = "vfat";
        options = [
          "dmask=0077"
          "fmask=0077"
        ];
      };

      "/mnt/slave" = {
        device = "/dev/disk/by-uuid/xxxx";
        fsType = "ext4";
      };
    };

    hardware.cpu.amd.updateMicrocode = true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
