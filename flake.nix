{
  description = "sbox-tools: A lightweight, secure, and reproducible development sandbox based on NixOS and QEMU";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        # Standard build package for sbox-tools
        packages.sbox-tools = pkgs.callPackage ./default.nix {};
        packages.default = packages.sbox-tools;

        # Development environment for debugging sbox-tools itself
        devShells.default = import ./shell.nix { inherit pkgs; };
      }
    );
}
