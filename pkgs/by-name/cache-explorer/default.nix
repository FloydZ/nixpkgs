{
  lib,
  clangStdenv,
  fetchFromGitHub,
  re2c,
  z3,
  hiredis,
  cmake,
  ninja,
  nix-update-script,
  llvmPackages_18,
}:
clangStdenv.mkDerivation (finalAttrs: {
  pname = "cache-explorer";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "AveryClapp";
    repo = "Cache-Explorer";
    tag = "v${finalAttrs.version}";
    hash = "";
  };

  nativeBuildInputs = [
    cmake
    ninja
    re2c
    llvmPackages_18.llvm
  ];

  buildInputs = [
  ];

  #env = {
  #  ALIVE2_HOME = "$PWD";
  #};

  preBuild = ''
    cd backend/cache-simulator && mkdir -p build && cd ../..
    cd backend/llvm-pass && mkdir -p build &&  && cd ../..
    cd backend/runtime && mkdir -p build && ninja && cd ../..
  '';

  buildPhase = ''
    cd backend/cache-simulator && mkdir -p build && cd build && cmake .. -G Ninja && ninja && cd ../../..
    cd backend/llvm-pass && mkdir -p build && cd build && cmake .. -G Ninja -DLLVM_DIR=$(llvm-config --cmakedir) && ninja && cd ../../..
    cd backend/runtime && mkdir -p build && cd build && cmake .. -G Ninja && ninja && cd ../../..
  '';


  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp alive $out/bin/
    cp alive-jobserver $out/bin/
    rm -rf $out/bin/CMakeFiles $out/bin/*.o
    cp *.a $out/lib
    cp tools/* $out/lib
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "";
    homepage = "https://github.com/AveryClapp/Cache-Explorer";
  };
})
