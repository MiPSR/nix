{ pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;
    languages = {
      language-server = {
        nixd = {
          command = "${lib.getExe pkgs.nixd}";
          args = [ "--semantic-tokens=true" ];
          config.nixd =
            let
              nixosConfiguration = "ui";
              flakeRef = "(builtins.getFlake (toString /home/m/code/nix))";
              nixosOpts = "${flakeRef}.nixosConfigurations.${nixosConfiguration}.options";
            in
            {
              nixpkgs.expr = "${flakeRef}.inputs.nixpkgs";
              options = {
                nixos.expr = nixosOpts;
                home-manager.expr = "${nixosOpts}.home-manager.users.type.getSubOptions []";
              };
            };
        };
      };
    };
  };
}
