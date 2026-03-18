{ lib
, stdenv
, fetchFromGitHub
, libllvm
, libclang
, libxml2
, pkg-config
, cmake
}:
let 
in
stdenv.mkDerivation rec {
  name = "lshaz";
  pname = "lshaz";
  version = "v0.0.1";
  
  src = fetchFromGitHub {
    owner = "abokhalill";
    repo = name;
    rev = "7270b21255a98615563cb1d7262dc1c07686db41";
    sha256 = "sha256-HjblqRzcuFD3T1Hc3HeSiyWnvWTCgyrqlgEFp9ilvs4=";
  };

  cmakeFlags = [
  ];
      
  nativeBuildInputs = [ 
    cmake
    pkg-config
    libllvm
    libclang
    libxml2
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp lshaz $out/bin
  '';
  
  meta = {
    description = "Find the microarchitectural performance bugs hiding in your C++ code ";
    homepage = "https://github.com/abokhalill/lshaz"; 
  };
}
