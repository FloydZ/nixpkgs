{ lib
, stdenv
, callPackage
, fetchFromGitHub
, pkg-config
, cmake
, gbenchmark
, zlib
, zstd
, microsoft-gsl
}:
let 
  # assemblyline =  callPackage ./../assemblyline/default.nix { };
in
stdenv.mkDerivation rec {
  name = "SEAL";
  pname = "seal";
  version = "4.1.2";
  
  src = fetchFromGitHub {
    owner = "microsoft";
    repo = name;
    rev = "${version}";
    sha256 = "sha256-LerJryT0TEc5HUz4SVa04BDFGfcgdxr+erPO3Vw0eSU=";
  };

  cmakeFlags = [
      "-DSEAL_BUILD_DEPS=OFF"
      "-DSEAL_USE_ZSTD=OFF"
      "-DSEAL_BUILD_EXAMPLES=ON"
  ];
      
  nativeBuildInputs = [ 
    cmake
    gbenchmark 
    zlib 
    # zstd is disabled, as its needs to be static. no idea
    zstd
    pkg-config
    microsoft-gsl
  ];

  buildInputs = [
  ];

    # TODO fix the double "//" in the pkg-config file
  fixupPhase = '' 
      echo test
  '';
  
  meta = {
    description = "Microsoft SEAL is an easy-to-use and powerful homomorphic encryption library.";
    homepage = "https://github.com/microsoft/${name}"; 
  };
}
