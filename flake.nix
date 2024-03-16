{
  description = "OpenStack Platform";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    devshell.url = "github:numtide/devshell";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    devshell,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [devshell.overlays.default];
        };

        python3 = pkgs.python3.withPackages (ps:
          builtins.attrValues {
            inherit
              (ps)
              jmespath
              ansible-core
              ;
          });
      in
        pkgs.devshell.mkShell {
          packages =
            builtins.attrValues {
              inherit
                (pkgs)
                ansible-lint
                ;
            }
            ++ [python3];
        };
    });
}
