{ callPackage, fetchFromGitHub, makeRustPlatform }:

# The date of the nighly version to use.
date:
let
  mozillaOverlay = fetchFromGitHub {
    owner = "mozilla";
    repo = "nixpkgs-mozilla";
    rev = "e6ca26fe8b9df914d4567604e426fbc185d9ef3e";
    sha256 = "sha256-SZcJEM+NnLr8ctzeQf1BGAqBHzJ3jn+tdSeO7lszIJc=";
  };
  mozilla = callPackage "${mozillaOverlay.out}/package-set.nix" {};
  rustNightly = (mozilla.rustChannelOf { inherit date; channel = "nightly"; }).rust;
in makeRustPlatform {
  cargo = rustNightly;
  rustc = rustNightly;
}
