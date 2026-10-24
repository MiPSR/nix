{ ... }: {
  flake.nixosModules.feature-steam = {
    programs.steam = {
      enable = true;

      gamescopeSession.enable = true;
    };
  };
}
