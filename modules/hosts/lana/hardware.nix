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

        luks.devices."master".device = "/dev/disk/by-uuid/14b20177-3860-4988-b6a6-2cb995de5abf";
      };

      kernelModules = [ "kvm-amd" ];
    };

    fileSystems = {
      "/" = {
        device = "/dev/mapper/master";
        fsType = "f2fs";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/8B83-666A";
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
