{ lib
, stdenv
, fetchgit
, automake
, linuxHeaders
}:

stdenv.mkDerivation rec {
  name = "nanoBench";
  pname = "nanoBench";
  version = "v1.0.0";
  
  src = fetchgit {
    url = "https://github.com/andreas-abel/nanoBench";
    rev = "faf75236cade57f7927f9ee949ebc679fc7864b7";
    sha256 = "sha256-n08/M6I/5+ZG61cqmCVEmAOnZiSLVU4tdBKkeIQRxM0=";
  };

  nativeBuildInputs = [ 
    automake
  ];

  buildInputs = [
    linuxHeaders
  ];
  
  buildPhase = ''
    # kernel build phase
    #cd kernel
    #make 
    #cd ..

    # user build phase
    cd user
    make
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/bin/user

    cp -r ${src}/configs $out/bin
    cp ${src}/disable-HT.sh $out/bin
    cp ${src}/enable-HT.sh $out/bin
    cp ${src}/kernel-nanoBench.sh $out/bin
    cp ${src}/nanoBench.sh $out/bin
    cp ${src}/single-core-mode.sh $out/bin
    cp ${src}/utils.sh $out/bin
    cp nanoBench $out/bin/user
  '';
  
  meta = {
    description = "A tool for running small microbenchmarks on recent Intel and AMD x86 CPUs.";
    homepage = "https://github.com/andreas-abel/${name}"; 
  };
}
