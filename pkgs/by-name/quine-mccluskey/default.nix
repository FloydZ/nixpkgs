{ lib
, stdenv
, callPackage
, fetchgit
, gnumake
, gcc
}:
stdenv.mkDerivation{
  name = "Quine_McCluskey";
  pname = "Quine_McCluskey";
  version = "v2.1.1";
  
  src = fetchgit {
    url = "https://github.com/hellman/Quine-McCluskey";
    rev = "5705f579471d5a117c9cf1698f2d2cdcd58bb23c";
    sha256 = "sha256-vOd5YndwBF2S6U9Z9gig1xMnSPUHHMeArPnFIUcip6c=";
  };

  nativeBuildInputs = [ 
    gnumake
    gcc
  ];

  buildPhase = ''
    make 
  '';

  installPhase = ''
    mkdir -p $out/bin

    cp denseqmc $out/bin
    cp sparseqmc $out/bin
    cp sparseqmcext $out/bin
  '';
  
  meta = {
    description = "DenseQMC: A bit-slice implementation of the Quine-McCluskey algorithm";
    homepage = "https://github.com/hellman/"; 
  };
}
