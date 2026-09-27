{ self, ... }: {
  flake.nixosModules.feature-amdgpu = { ... }: {
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
