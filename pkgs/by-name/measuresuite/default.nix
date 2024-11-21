{ lib
, stdenv
, callPackage
, fetchFromGitHub
, gnumake
, pkg-config
, which
}:
let 
  assemblyline =  callPackage ./../assemblyline/default.nix { };
in
stdenv.mkDerivation rec {
  name = "MeasureSuite";
  pname = "MeasureSuite";
  version = "v2.1.1";
  
  src = fetchFromGitHub {
    owner = "0xADE1A1DE";
    repo = name;
    rev = "refs/tags/${version}";
    sha256 = "sha256-IGmwIPofAZmMn02fblAw2CkdJi8qyiUk+uMmwYO3o1g=";
  };

  nativeBuildInputs = [ 
    gnumake
    pkg-config
    which
  ];

  buildInputs = [
    assemblyline
  ];

  buildPhase = ''
    make LDLIBS="-L${assemblyline}/lib -lassemblyline" CPPFLAGS="-I./src/ -I./src/include -I${assemblyline}/dev -DUSE_ASSEMBLYLINE"
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib

    cp ms $out/bin
    cp bin/msc $out/bin

    cp lib/libmeasuresuite.so $out/lib
    cp lib/libmeasuresuite.a $out/lib
  '';
  
  meta = {
    description = "This library measures the execution time for code. Can measure asm (with Assemblyline), o, so, bin files. Can check correctness (equality of all functions on output data) and the output is a JSON with robust cycle counts. ";
    homepage = "https://github.com/0xADE1A1DE/${name}"; 
  };
}
