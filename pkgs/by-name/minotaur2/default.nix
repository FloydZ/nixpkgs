{ lib
, stdenv
, callPackage
, fetchFromGitHub
, cmake
, ninja
, z3
, redis
, hiredis
, perl
, perlPackages
, re2c
, llvmPackages_git
}:
let 
  alive2 = callPackage ./alive2.nix { };
#  llvmPkgs =
#    (llvmPackages_git.override {
#      config = {
#        enableRtti = true;
#        enableEh = true;
#        buildLlvmDylib = true;
#        linkLlvmDylib = true;
#        # These two may or may not be used by the current llvmPackages_git,
#        # but we’ll force the CMake flags below regardless.
#        enableTests = false;
#        doCheck = false;
#      };
#    }).overrideScope (final: prev: {
#      # THIS is where the real LLVM CMake build happens:
#      libllvm = prev.libllvm.overrideAttrs (old: {
#        patches = (old.patches or []) ++ [ ./llvm-main-minotaur.patch ];
#        doCheck = false;
#        cmakeFlags = (old.cmakeFlags or []) ++ [
#          "-DLLVM_INCLUDE_TESTS=OFF"
#          "-DLLVM_BUILD_TESTS=OFF"
#          "-DLLVM_INCLUDE_BENCHMARKS=OFF"
#          "-DLLVM_INCLUDE_EXAMPLES=OFF"
#        ];
#      });
#    });
# llvm  = llvmPkgs.llvm;
# clang = llvmPkgs.clang;
  llvm  = llvmPackages_git.llvm;
  clang = llvmPackages_git.clang;
in
stdenv.mkDerivation rec {
  pname = "minotaur-toolkit-minotaur";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "minotaur-toolkit";
    repo = "minotaur";
    rev = "dev";
    sha256 = "sha256-3QFV0frflU4fggQT/lPu0bJeu+HR0w/kvRK+IBQOl3s=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    re2c
    perl
    perlPackages.Redis
    redis
    hiredis
    alive2
    llvm
    clang
  ];

  buildInputs = [
    redis
    hiredis
    z3
    llvm
    clang
  ];

  NIX_CFLAGS_COMPILE = toString [
    "-fexceptions"
  ];
  NIX_CXXFLAGS_COMPILE = toString [
    "-fexceptions"
    "-I${llvm.dev}/include"
  ];
  CXXFLAGS = toString [
    "-fexceptions"
    "-I${llvm.dev}/include"
  ];

    #patches = [
    #  ./plugin.patch
    #];
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'find_package(Git REQUIRED)' ""
    
    substituteInPlace scripts/minotaur-cc.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${clang}"
    substituteInPlace scripts/minotaur-cc.in \
      --replace-fail '@ONLINE_PASS@' "$out/lib/online.so"


    substituteInPlace scripts/opt-minotaur.sh.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${clang}"
    substituteInPlace scripts/opt-minotaur.sh.in \
      --replace-fail '@ONLINE_PASS@' "$out/lib/online.so"

    substituteInPlace scripts/infer-cut.sh.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${clang}"
    substituteInPlace scripts/infer-cut.sh.in \
      --replace-fail '@ONLINE_PASS@' "$out/lib/online.so"


    substituteInPlace scripts/slice-cc.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${clang}"
    substituteInPlace scripts/cache-dump.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${clang}"
    substituteInPlace scripts/cache-infer.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${clang}"
    substituteInPlace scripts/get-cost.in \
      --replace-fail '@LLVM_BINARY_DIR@/bin/clang' "${clang}/bin/clang"
    substituteInPlace scripts/get-cost.in \
      --replace-fail '@LLVM_BINARY_DIR@/bin/llvm-mca' "${llvm}/bin/llvm-mca"
    substituteInPlace include/cost-command.h.in \
      --replace-fail '@CMAKE_BINARY_DIR@' "$out/bin"

      cat include/cost-command.h.in
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DLLVM_DIR=${llvm.dev}/lib/cmake/llvm"
    "-DALIVE2_SOURCE_DIR=${alive2.src}"
    "-DALIVE2_BUILD_DIR=${alive2.out}"
    "-DALIVE2_SMT_LIBS=${alive2.out}/lib/libsmt.a"
    "-DALIVE2_TOOLS_LIBS=${alive2.out}/lib/libtools.a"
    "-DALIVE2_UTIL_LIBS=${alive2.out}/lib/libutil.a"
    "-DALIVE2_IR_LIBS=${alive2.out}/lib/libir.a"
    "-DALIVE2_LLVM_UTIL=${alive2.out}/lib/libllvm_util.a"
  ];

  checkPhase = ''
    cd build
    ninja check
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    
    cp cache-dump          $out/bin
    cp cache-infer         $out/bin
    cp get-cost            $out/bin
    cp infer-cut.sh        $out/bin
    cp libconfig.a         $out/lib
    cp libcost.a           $out/lib
    cp libslice.a          $out/lib
    cp libsynthesizer.a    $out/lib
    cp libutils.a          $out/lib
    cp minotaur-c++        $out/bin
    cp minotaur-cc         $out/bin
    cp minotaur-cs         $out/bin
    cp minotaur-slice      $out/bin
    cp online.so           $out/lib
    cp slice-c++           $out/bin
    cp slice-cc            $out/bin
  '';

  meta = with lib; {
    description = "Minotaur: a synthesizing superoptimizer for LLVM";
    homepage = "https://github.com/minotaur-toolkit/minotaur";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux;
  };
}
