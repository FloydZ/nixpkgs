{}:
let
  pkgs = import <nixpkgs> {

    system = "x86_64-linux";
    overlays = [ (import ./llvm_23.nix) ];
  };
in
pkgs.callPackage ./minotaur.nix { }
