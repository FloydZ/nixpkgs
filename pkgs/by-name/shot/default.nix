{ lib
, stdenv
, callPackage
, fetchgit
, cmake
, coinmp
, coin-utils
}:
let
in stdenv.mkDerivation rec {
  pname = "shot";
  version = "master";

  src = fetchgit {
    url = "https://github.com/coin-or/SHOT/";
    rev = "2a3f4f66a546b95f77a1fe5e90f543d1c898ad85";
    hash = "sha256-vKEGOl09V2KNkO5z92qylA/AdnBimL1FRPd2hyoas98=";
  };

  nativeBuildInputs = [ 
    cmake 
  ];
  buildInputs = [
    coinmp
    coin-utils
  ];

  cmakeFlags = [
    "-DHAS_CBC=ON"
    "-DCBC_DIR=${coinmp}"
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    mkdir -p $out/dev

    ls -R .

    cp SHOT $out/bin
    cp libSHOTSolver.so $out/lib

    cp libSHOTDualStrategy.a $out/lib
    cp libSHOTHelper.a $out/lib
    cp libSHOTModel.a $out/lib
    cp libSHOTModelingInterfaces.a $out/lib
    cp libSHOTPrimalStrategy.a $out/lib
    cp libSHOTResults.a $out/lib
    cp libSHOTSolutionStrategies.a $out/lib
    cp libSHOTTasks.a $out/lib
    cp libtinyxml2.a $out/lib
  '';

  meta = with lib; {
    description = "A solver for mixed-integer nonlinear optimization problems ";
    homepage = "shotsolver.dev";
    license = licenses.ncsa;
    platforms = [ "x86_64-linux" ];
    # maintainers = with maintainers; [ ];
  };
}
