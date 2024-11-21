{ lib
, stdenv
, callPackage
, fetchgit
, gnumake
, gcc11
, cudatoolkit
}:
stdenv.mkDerivation{
  name = "ParaFROST";
  pname = "ParaFROST";
  version = "v0.4.0";
  
  src = fetchgit {
    url = "https://github.com/muhos/ParaFROST/";
    rev = "89cd346cc55d106d5d36bac54277f218ab000d4b";
    sha256 = "sha256-ekN3F+xvgqxbgyTlEztmW/z32UAObIFvBPXHbQ4LjP0=";
  };

  nativeBuildInputs = [ 
    gnumake
    gcc11
  ];

  buildInputs = [ 
    cudatoolkit
  ];

  buildPhase = ''
    export CUDA_PATH=${cudatoolkit}
    ./install.sh -c
    ./install.sh -g
  '';

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/bin
   
    cp ./build/cpu/parafrost $out/bin/parafrost_cpu
    cp ./build/gpu/parafrost $out/bin
    cp ./build/gpu/libparafrost.a $out/lib
  '';
  
  meta = {
    description = "A Parallel SAT Solver with GPU Accelerated Inprocessing";
    homepage = "https://github.com/TODO/"; 
  };
}
