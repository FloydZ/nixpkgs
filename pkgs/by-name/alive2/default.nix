{ lib
, stdenv
, callPackage
, fetchgit
, cmake
, clang
, llvm
, re2c
, z3
, gperftools
, sqlite
, lit
, git
}:

let
in stdenv.mkDerivation rec {
  pname = "alive2";
  version = "7";

  src = fetchgit {
    url = "https://github.com/manasij7479/alive2/";
    # v4
    #rev = "v4";
    #hash = "sha256-GdNVU+pzOb8J0Mvq8yUVwPsUPqKOvn/2RfqoRrzfvPk=";
    
    # v7
    #rev = "v7";
    rev = "c003606d9cb013453f7352b0ca25d22d73148685";
    hash = "sha256-F9GcDEuMQE42GUFdUFU5SA4tmRDYc7ChOQpBK1j+hVc=";
  };

  patches = [
    ./v7.patch
    # ./v4.patch
  ]; 

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    llvm
    clang
    z3
    re2c
    gperftools
    sqlite
    lit
    git
  ];

  cmakeFlags = let
    onOff = val: if val then "ON" else "OFF";
  in [
    #"-DZ3_LIBRARIES=${z3}/lib/libz3.so"
    #"-DZ3_INCLUDE_DIR=${z3}/include"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_TESTING=OFF"
    "-DLLVM_ENABLE_RTTI=ON"
    "-DLLVM_ENABLE_EH=ON"
    "-DBUILD_SHARED_LIBS=ON"
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    mkdir -p $out/dev
    cp ./alive $out/bin
    # cp ./alive-jobserver $out/bin
    cp libir.a $out/lib
    cp libsmt.a $out/lib
    cp libtools.a $out/lib
    cp libutil.a $out/lib
  '';

  meta = with lib; {
    description = "Alive2 consists of several libraries and tools for analysis and verification of LLVM code and transformations. Alive2 includes the following libraries:";
    homepage = "https://github.com/AliveToolkit/alive2";
    license = licenses.ncsa;
    platforms = [ "x86_64-linux" ];
    # maintainers = with maintainers; [ ];
  };
}
