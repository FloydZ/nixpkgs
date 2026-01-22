{ lib
, stdenv
, clangStdenv
, fetchFromGitHub
, fetchgit
, cmake
, ninja
, z3
, redis
, hiredis
, perl
, perlPackages
, re2c
, callPackage
#, llvmPackages_23
#, llvmPackages_21
, llvmPackages_git
}:
let 
  alive2 =  callPackage ./alive2.nix { };
  #llvmA =  callPackage ./llvm_23.nix { };
  #llvmPackages_23 = llvmA.llvmPackages_23;

  # this works with `_21`
  llvmPkgs = llvmPackages_git.override {
    config = {
      enableRtti = true;
      enableEh = true;
      buildLlvmDylib = true;
      linkLlvmDylib = true;
    };
  };
  llvm = llvmPkgs.llvm.overrideAttrs (oldAttrs: rec {
    patches = oldAttrs.patches ++ [ ./llvm-main-minotaur.patch ];
    doCheck = false;
  });

  # this is currently `llvmPackages_23`
  #llvm = llvmPackages_git.llvm.overrideAttrs (oldAttrs: rec {
  #  release_version = "23.0.0";
  #  version = "23.0.0";
  #  src = fetchgit {
  #    url = "https://github.com/llvm/llvm-project.git";
  #    rev = "1c4e03aa2619339248c77b0f0ebd564e766415ef";
  #    sha256 = "sha256-WaVmQu0YFaypbEMH2y5KX7M5Qn/BXaQFdExfcJI2yo4=";
  #  };

  #  patches =
  #    (lib.filter (p:
  #      let s = toString p;
  #      in !(lib.hasInfix "gnu-install-dirs-polly.patch" s
  #        || lib.hasInfix "polly" s)) oldAttrs.patches)
  #    ++ [ ./llvm-main-minotaur.patch ];
  #});
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
    llvmPkgs.clang
  ];

  buildInputs = [
    redis
    hiredis
    z3
    llvm
    llvmPkgs.clang
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
      --replace-fail '@LLVM_BINARY_DIR@' "${llvmPkgs.clang}"
    substituteInPlace scripts/minotaur-cc.in \
      --replace-fail '@ONLINE_PASS@' "$out/lib/online.so"


    substituteInPlace scripts/opt-minotaur.sh.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${llvmPkgs.clang}"
    substituteInPlace scripts/opt-minotaur.sh.in \
      --replace-fail '@ONLINE_PASS@' "$out/lib/online.so"

    substituteInPlace scripts/infer-cut.sh.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${llvmPkgs.clang}"
    substituteInPlace scripts/infer-cut.sh.in \
      --replace-fail '@ONLINE_PASS@' "$out/lib/online.so"


    substituteInPlace scripts/slice-cc.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${llvmPkgs.clang}"
    substituteInPlace scripts/cache-dump.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${llvmPkgs.clang}"
    substituteInPlace scripts/cache-infer.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${llvmPkgs.clang}"
    substituteInPlace scripts/get-cost.in \
      --replace-fail '@LLVM_BINARY_DIR@/bin/clang' "${llvmPkgs.clang}/bin/clang"
    substituteInPlace scripts/get-cost.in \
      --replace-fail '@LLVM_BINARY_DIR@/bin/llvm-mca' "${llvmPkgs.llvm}/bin/llvm-mca"
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
