{ ... }: {
  flake.nixosModules.host-roxy-hardware =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      boot = {
        initrd.availableKernelModules = [
          "nvme"
          "sd_mod"
          "usb_storage"
          "usbhid"
          "xhci_pci"
          "xhci_pci_renesas"
        ];

        initrd.luks.devices."master" = {
          device = "/dev/disk/by-uuid/3a5435a5-e772-40d3-ae57-a9cf4dc0fe15";
          bypassWorkqueues = true;
          allowDiscards = true;
        };

        kernelModules = [ "kvm-amd" ];
      };

      fileSystems = {
        "/" = {
          device = "/dev/mapper/master";
          fsType = "f2fs";
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/1291-368A";
          fsType = "vfat";
          options = [
            "dmask=0077"
            "fmask=0077"
          ];
        };
      };

      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
