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
          "usbhid"
          "xhci_pci"
          "xhci_pci_renesas"
        ];

        initrd.luks.devices."luks-2e218e38-04d8-478c-8aac-567a0efb5934".device =
          "/dev/disk/by-uuid/2e218e38-04d8-478c-8aac-567a0efb5934";

        kernelModules = [ "kvm-amd" ];
      };

      fileSystems = {
        "/" = {
          device = "/dev/mapper/luks-2e218e38-04d8-478c-8aac-567a0efb5934";
          fsType = "ext4";
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/C602-7642";
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
