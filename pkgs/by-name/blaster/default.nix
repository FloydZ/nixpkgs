{ pkgs, lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication {
  pname = "blaster";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "ludopulles";
    repo = "BLASter";
    rev = "c6b9328bcf4ab6709d8f94f1bdd9e4b5491cd082";
    hash = "sha256-quyJSl9eLEQXjDPAFTisZqd3HvqXH/6Z7Uh1bukSM0E=";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
  ] ++ (with python3Packages; [
    cython
    setuptools
  ]);

  buildInputs = with pkgs; [
    eigen
    openblas
    gmp
    mpfr
  ];

  propagatedBuildInputs = with python3Packages; [
    numpy
    cysignals
  ];

  preBuild = ''
    ln -sf ${pkgs.eigen}/include/eigen3 eigen3
  '';

  meta = with lib; {
    description = "Fast lattice reduction using segmentation, multithreading, Seysen reduction and BLAS";
    homepage = "https://github.com/ludopulles/BLASter";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
