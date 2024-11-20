{ lib
, stdenv
, fetchgit
, python3 }:
stdenv.mkDerivation rec {
  name = "ternarylogiccli";
  pname = "ternarylogiccli";
  version = "0.0.1";
  
  src = fetchgit {
    url = "https://github.com/WojciechMula/ternarylogiccli";
    rev = "bee86ade57ccc21a30b8468551ee5f854fae24b1";
    sha256 = "sha256-2FD/vkny7RShM6OrXkxdeQX0ZRb7ob0ffO0Qp1L8Y4k=";
  };

  patches = [ ./bin.patch ];

  installPhase = ''
    mkdir -p $out/bin
    cp ternarylogiccli.py $out/bin
    cp ternarylogiccli $out/bin
  '';
  
  nativeBuildInputs = [
    python3
  ];
  meta = {
    description = "CLI utilty to work out proper constants for vpternlogic instruction";
    homepage = "https://github.com/WojciechMula/ternarylogiccli"; 
  };
}
