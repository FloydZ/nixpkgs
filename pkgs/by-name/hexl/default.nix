{ lib
, stdenv
, callPackage
, fetchFromGitHub
, pkg-config
, cmake
, easyloggingpp
, gbenchmark
, gtest
}:
let 
  cpu_features =  callPackage ./../cpu_features/default.nix { };
in
stdenv.mkDerivation rec {
  name = "hexl";
  pname = "hexl";
  version = "v1.2.5";
  
  src = fetchFromGitHub {
    owner = "intel";
    repo = name;
    rev = "${version}";
    sha256 = "sha256-AZAQ0l//WHHZW4rqyukldHjFLkm28e0zUfHFEGFy2h4=";
  };

  cmakeFlags = [
    "-DHEXL_TESTING=OFF"
    "-DHEXL_BENCHMARK=OFF"
  ];
      
  nativeBuildInputs = [ 
    cmake
    gbenchmark 
    cpu_features
    pkg-config
    gtest
    easyloggingpp
  ];

  buildInputs = [
    gtest 
    gbenchmark
  ];

  meta = {
    description = "Intel:registered: Homomorphic Encryption Acceleration Library accelerates modular arithmetic operations used in homomorphic encryption ";
    homepage = "https://github.com/intel/${name}"; 
  };
}
