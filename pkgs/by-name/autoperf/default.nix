{ pkgs, lib, fetchgit, callPackage}:
let
  rustPlatform = callPackage ./rust-platform-nightly.nix {};
in (rustPlatform "2023-05-10").buildRustPackage rec {
  pname = "autoperf";
  version = "0.0.1";

  src = fetchgit {
    url = "https://github.com/gz/autoperf";
    rev = "17d5615061392e6fc4ca33e57e689485846e59bb";
    sha256 = "sha256-eQv4Lt9lla6XSDPn2c44dpOzSraDrrU1HHXcKpbXpUE=";
  };

  cargoHash = lib.fakeHash;
  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
    '';

  buildInputs = with pkgs; [ 
    cpuid
    hwloc
    numactl
  ];

  meta = with lib; {
    description = "Simplify the use of performance counters.";
    homepage = "https://docs.rs/crate/autoperf/latest";
    license = licenses.unlicense;
  };
}
