{ self, ... }: {
  flake.nixosModules.feature-amdgpu = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      vulkan-loader
    ];

    hardware = {
      alsa.enablePersistence = true;
      amdgpu.opencl.enable = true;
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}
