{ pkgs, lib, stdenv, fetchgit }:
stdenv.mkDerivation {
  pname = "blaster";
  version = "0.0.1";

  src = fetchgit {
    url = "https://github.com/ludopulles/BLASter";
    rev = "c6b9328bcf4ab6709d8f94f1bdd9e4b5491cd082";
    sha256 = "sha256-quyJSl9eLEQXjDPAFTisZqd3HvqXH/6Z7Uh1bukSM0E=";
  };

  nativeBuildInputs = with pkgs; [
    fplll
    python3
  ];

  buildInputs = with pkgs; [
    cmake
    clang
    gbenchmark
    gmp
    mpfr
    eigen
    openblas
    pkg-config
  ];

  #installPhase = ''
  #'';
  
  meta = with lib; {
    description = " Fast lattice reduction using segmentation, multithreading, Seysen reduction and BLAS ";
    homepage = "https://github.com/ludopulles/BLASter";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
