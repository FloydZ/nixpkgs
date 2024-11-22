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
  pname = "parafrost";
  version = "v3.4.2";
  
  src = fetchgit {
    url = "https://github.com/muhos/ParaFROST/";
    rev = "23dc65781ff892e9fe75265d707541b21e6d1439";
    sha256 = "sha256-wOQPtg9ET9MaM+nftEcS7CmS5V0IkCKANMn1xU/XJVI=";
  };

  nativeBuildInputs = [ 
    gnumake
    gcc11
    cudatoolkit
  ];

  buildInputs = [ 
    cudatoolkit
  ];

  buildPhase = ''
    export CUDA_PATH=${cudatoolkit}
    bash install.sh -c
    bash install.sh -g
  '';

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/bin
    mkdir -p $out/dev
   
    cp ./build/cpu/bin/parafrost $out/bin/parafrost_cpu
    cp ./build/cpu/lib/libparafrost.a $out/lib/libparafrost.a

    cp ./build/gpu/bin/parafrost $out/bin
    cp ./build/gpu/lib/libparafrost.a $out/lib
    # cp ./build/gpu/include/* $out/dev/*
  '';
  
  meta = {
    description = "A Parallel SAT Solver with GPU Accelerated Inprocessing";
    homepage = "https://github.com/TODO/"; 
  };
}
