{ self, ... }: {
  flake.nixosModules.feature-retro = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      _86box-with-roms
    ];
  };
}
