{ stdenv
, lib
, fetchFromGitHub
, z3
, gcc13
, autoconf
, gnumake
, overrideCC
, which
, gmp
}:

let
in (overrideCC stdenv gcc13).mkDerivation rec {
  pname = "smtgcc";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "kristerw";
    repo = pname;
    rev = "c2f468026a9ce60a8cc883a89a878dee1bb53a21";
    sha256 = "sha256-ZeFYdxEZPCiP2T4SUJYt62jruP4db6RqyoArDf33KEU=";
  };

  buildInputs = [
    z3
  ];

  nativeBuildInputs = [
    autoconf
    gnumake
    gcc13
    which
    gmp
  ];

  buildPhase = ''
    ./configure --with-target-compiler=${gcc13}/bin/gcc
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib

    cp smtgcc-tv.so $out/lib
    cp smtgcc-tv-backend.so $out/lib
    cp smtgcc-check-refine.so $out/lib

    cp smtgcc-check-refine $out/bin
    cp smtgcc-check-ub $out/bin
    cp smtgcc-opt $out/bin
  '';
}
