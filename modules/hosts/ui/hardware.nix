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

        luks.devices."master".device = "/dev/disk/by-uuid/35d4e337-3c1d-41ff-bced-eadcdd6a44e5";
      };

      kernelModules = [ "kvm-amd" ];
    };

    fileSystems = {
      "/" = {
        device = "/dev/mapper/master";
        fsType = "f2fs";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/D92E-2AC0";
        fsType = "vfat";
        options = [
          "dmask=0077"
          "fmask=0077"
        ];
      };
    };

    hardware.cpu.amd.updateMicrocode = true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
