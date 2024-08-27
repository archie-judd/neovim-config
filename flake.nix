{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = { flake-utils, nixpkgs, nixpkgs-stable, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-stable = nixpkgs-stable.legacyPackages.${system};

        nvim = pkgs.callPackage ./nvim.nix {
          pkgs = pkgs;
          pkgs-stable = pkgs-stable;
        };

        app = pkgs.writeShellApplication {
          name = "nvim";
          text = "${nvim.package}/bin/nvim";
          runtimeInputs = nvim.extraPackages;
        };

      in {
        packages.default = app;

      });
}

