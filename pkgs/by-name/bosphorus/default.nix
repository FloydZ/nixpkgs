{ lib
, stdenv
, callPackage
, fetchgit
, cmake
, m4ri
, cryptominisat
, zlib
, brial
, boost
}:
stdenv.mkDerivation rec {
  name = "bosphorus";
  pname = "bosphorus";
  version = "v3.1.0";
  
  src = fetchgit {
    # owner = "meelgroup";
    #repo = name;
    url = "https://github.com/meelgroup/bosphorus/";
    rev = "3cd6cea582e10dc9969f104f5a52ad4706bc1d91";
    sha256 = "sha256-Yz90qqhS9KFYm+sTIK43w2bKCgbLZtRXKoO4SEptloY=";
  };

  nativeBuildInputs = [ 
    cmake
  ];

  buildInputs = [
    m4ri
    cryptominisat
    zlib
    brial
    boost
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    ls -R

    cp bosphorus $out/bin
    cp lib/libbosphorus.so $out/lib
    cp lib/libbosphorus.so.3.1 $out/lib
  '';
  
  meta = {
    description = "DenseQMC: A bit-slice implementation of the Quine-McCluskey algorithm";
    homepage = "https://github.com/hellman/"; 
  };
}
