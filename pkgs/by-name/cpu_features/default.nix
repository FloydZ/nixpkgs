{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, cmake
}:
let 
in
stdenv.mkDerivation rec {
  name = "cpu_features";
  pname = "cpu_features";
  version = "v0.9.0";
  
  src = fetchFromGitHub {
    owner = "google";
    repo = name;
    rev = "${version}";
    sha256 = "sha256-uXN5crzgobNGlLpbpuOxR+9QVtZKrWhxC/UjQEakJwk=";
  };

  cmakeFlags = [
  ];
      
  nativeBuildInputs = [ 
    cmake
    pkg-config
  ];

  buildInputs = [
  ];
  
  meta = {
    description = "A cross platform C99 library to get cpu features at runtime. ";
    homepage = "https://github.com/google/${name}"; 
  };
}
