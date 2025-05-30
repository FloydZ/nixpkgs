{ stdenv
, fetchgit
, gnumake
, gcc
, cudatoolkit
, cudaPackages
, linuxPackages
}:
stdenv.mkDerivation{
  name = "ParaFROST";
  pname = "parafrost";
  version = "v3.4.4";
  
  src = fetchgit {
    url = "https://github.com/muhos/ParaFROST/";
    # 3.4.2
    #rev = "23dc65781ff892e9fe75265d707541b21e6d1439";
    #sha256 = "sha256-wOQPtg9ET9MaM+nftEcS7CmS5V0IkCKANMn1xU/XJVI=";
    # 3.4.4
    rev = "077577248ffe30db1dc0ced81df76520c1606925";
    sha256 = "sha256-9tKt9ouozUIvr89pKpt9PGXsttgfugA6Ap60icJblxc=";
  };

  nativeBuildInputs = [ 
    gnumake
    gcc
    cudatoolkit
    cudaPackages.cuda_cudart
    linuxPackages.nvidia_x11
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
    homepage = "https://github.com/muhos/ParaFROST"; 
  };
}
