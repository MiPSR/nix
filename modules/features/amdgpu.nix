{ self, ... }: {
  flake.nixosModules.feature-amdgpu = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      vulkan-loader
    ];

    hardware = {
      alsa.enablePersistence = true;
      amdgpu = {
        opencl.enable = true;
        overdrive.enable = true;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    services.lact.enable = true;
  };
}
