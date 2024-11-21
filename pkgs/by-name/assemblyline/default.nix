{ lib
, stdenv
, fetchFromGitHub
, automake
, autoconf
, libtool
, pkg-config
}:

stdenv.mkDerivation rec {
  name = "Assemblyline";
  pname = "Assemblyline";
  version = "v1.3.2";
  
  src = fetchFromGitHub {
    owner = "0xADE1A1DE";
    repo = name;
    rev = "refs/tags/${version}";
    sha256 = "sha256-Et22KHDNmw/7MK7WFsm+H4eHncJWBn53czufgTexa+M=";
  };

  nativeBuildInputs = [ 
    pkg-config
    autoconf
    automake
    libtool
  ];
  
  buildPhase = ''
    ./autogen.sh 
    ./configure
    make 
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    mkdir -p $out/dev
    
    cp $src/src/assemblyline.h $out/dev

    cp tools/asmline $out/bin 
    cp .libs/libassemblyline.a $out/lib
    cp .libs/libassemblyline.so $out/lib
    cp .libs/libassemblyline.so.1 $out/lib
    cp .libs/libassemblyline.so.1.2.5 $out/lib
  '';
  
  meta = {
    description = " A C library and binary for generating machine code of x86_64 assembly language and executing on the fly without invoking another compiler, assembler or linker. ";
    homepage = "https://github.com/0xADE1A1DE/${name}"; 
  };
}
