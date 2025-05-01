{ pkgs, lib, stdenv, fetchgit }:
stdenv.mkDerivation {
  pname = "flatter";
  version = "0.0.1";

  src = fetchgit {
    url = "https://github.com/keeganryan/flatter";
    rev = "13c4ef0f0abe7ad5db88b19a9196c00aa5cf067c";
    sha256 = "sha256-k0FcIJARaXi602eqMSum+q1IaCs30Xi0hB/ZNNkXruw=";
  };

  nativeBuildInputs = with pkgs; [
      cmake
      clang
  ];

  buildInputs = with pkgs; [
    gbenchmark
    gmp
    mpfr
    fplll
    eigen
    openblas
    pkg-config
  ];

  #installPhase = ''
  #'';
  
  meta = with lib; {
    description = "Fast lattice reduction";
    homepage = "https://github.com/keeganryan/flatter"; 
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
