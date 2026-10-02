{ ... }: {
  flake.nixosModules.host-homura-hardware = { lib, ... }: {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sr_mod"
    ];
    boot.kernelModules = [ "kvm-intel" ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/2b85d666-b4de-4d3f-9be1-f2f1db255275";
      fsType = "f2fs";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/5942-15FF";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = true;
  };
}
