{ lib
, stdenv
, clangStdenv
, fetchFromGitHub
, fetchgit
, cmake
, ninja
, llvmPackages_git
, z3
, redis
, hiredis
, perl
, re2c
, callPackage
, llvmPackages_21
}:
let 
  alive2 =  callPackage ./alive2.nix { };

  llvmPkgs = llvmPackages_21.override {
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
  #llvm = llvmPkgs.llvm;

  # this is currently `llvmPackages_22`
  #llvmPkgs = llvmPackages_git.override {
  #  config = {
  #    enableRtti = true;
  #    enableEh   = true;
  #  };
  #};
  #llvm = llvmPkgs.llvm.overrideAttrs (oldAttrs: rec {
  #  patches = oldAttrs.patches ++ [ ./llvm-main-minotaur.patch ];
  #  doCheck = false;
  #});

  # this is currently `llvmPackages_23`
  #llvm = llvmPackages_git.llvm.overrideAttrs (oldAttrs: rec {
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

  patches = [
    ./plugin.patch
  ];
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
    substituteInPlace scripts/get-cost.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${llvmPkgs.clang}"
    substituteInPlace scripts/cache-dump.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${llvmPkgs.clang}"
    substituteInPlace scripts/cache-infer.in \
      --replace-fail '@LLVM_BINARY_DIR@' "${llvmPkgs.clang}"
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

#{ lib
#, stdenv
#, fetchgit
#, callPackage
#, z3
#, cmake
#, ninja
#, git
#, llvmPackages
#, re2c
#, redis
#, hiredis
#, gtest
#, python3
#, llvmPackages_20
#}:
#let
#  #customAlive2 =  callPackage ./../alive2/default.nix { };
#  cAlive2 = fetchgit {
#    url = "https://github.com/alivetoolkit/alive2/";
#    rev = "v21.0";
#    hash = "sha256-LL6/Epn6iHQJGKb8PX+U6zvXK/WTlvOIJPr6JuGRsSU=";
#  };
#
#  #cLLVM = fetchgit {
#  #    url = "https://github.com/llvm/llvm-project.git";
#  #    rev = "llvmorg-21.1.8";
#  #    sha256 = "sha256-pgd8g9Yfvp7abjCCKSmIn1smAROjqtfZaJkaUkBSKW0=";
#  #};
#  cLLVM = llvmPackages_20.llvm.overrideAttrs (oldAttrs: rec {
#    src = fetchgit {
#     url = "https://github.com/llvm/llvm-project.git";
#     rev = "llvmorg-21.1.8";
#     sha256 = "sha256-pgd8g9Yfvp7abjCCKSmIn1smAROjqtfZaJkaUkBSKW0=";
#    #  url = "https://github.com/llvm/llvm-project.git";
#    #  rev = "llvmorg-20.1.8";
#    #  sha256 = "sha256-pgd8g9Yfvp7abjCCKSmIn1smAROjqtfZaJkaUkBSKW0=";
#    };
#    #patches = oldAttrs.patches ++ [
#    patches = [
#      ./llvm-main-minotaur.patch
#    ];
#  });
#
#  cZ3 = z3.overrideAttrs (oldAttrs: rec {
#    src = fetchgit {
#      url = "https://github.com/Z3Prover/z3.git";
#      rev = "z3-4.15.4";
#      sha256 = "sha256-eyF3ELv81xEgh9Km0Ehwos87e4VJ82cfsp53RCAtuTo=";
#    };
#  });
#in
#stdenv.mkDerivation rec {
#  name = "minotaur";
#  pname = "minotaur";
#  version = "0.1.0";
#  
#  src = fetchgit {
#    url = "https://github.com/minotaur-toolkit/minotaur";
#    rev = "866204d727313a15209976d833316b3b3e779110";
#    sha256 = "sha256-eSiOChsJ/eQ6SNCKlh6/kUslgNEylGjLBK4z/l7/tBY=";
#  };
#
#  #enableParallelBuilding = true;
#
#  z3="${cZ3}";
#  alive2="${cAlive2}";
#
#  buildInputs = [
#    cLLVM
#    cmake
#    ninja 
#    git
#    re2c
#    redis
#    hiredis
#    gtest
#    python3
#  ];
#
#
#  nativeBuildInputs = [ 
#  ];
#
#  configurePhase = ''
#    # prepare Z3 
#    #ls -al
#    #mkdir -pv tmp/z3
#    #mkdir -pv tmp/z3/build
#    #mkdir -pv tmp/z3-install
#    #cp -r ${cZ3.src}/* tmp/z3 
#    #cd tmp/z3
#    #cmake -S ./ -B ./build -G Ninja  \
#    #  -DCMAKE_BUILD_TYPE=Release              \
#    #  -DCMAKE_INSTALL_PREFIX=tmp/z3-install   \
#    #  -DZ3_BUILD_TEST_EXECUTABLES=OFF         \
#    #  -DZ3_BUILD_EXECUTABLE=OFF
#    #cmake --build ./build --target install
#    #cd ../..
#
#    # prepare llvm
#    #mkdir -pv tmp/llvm
#    #mkdir -pv tmp/llvm/build
#    #mkdir -pv tmp/llvm-install
#    #cp -r ${cLLVM.src}/* tmp/llvm
#    #chmod -R 666 ./tmp/llvm
#    #cd tmp/llvm
#    #ls -al
#    ## git apply ../../llvm-main-minotaur.patch
#    #patch -p1 < ../../llvm-main-minotaur.patch 
#    #cmake -S${cLLVM.src} ./ -B ./build -G Ninja  \
#    #  -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_EH=ON    \
#    #  -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release         \
#    #  -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_ASSERTIONS=ON   \
#    #  -DLLVM_ENABLE_PROJECTS="llvm;clang"                       \
#    #  ../llvm-install 
#    #ninja
#    #cd ../..
#
#    # prepare alive
#    mkdir -pv tmp/alive2
#    mkdir -pv tmp/alive2/build
#    mkdir -pv tmp/alive2-install
#    cd tmp/alive2
#    cp -r ${cAlive2}/* tmp/alive2
#    cmake -G Ninja -DLLVM_DIR=${cLLVM.src}/ \
#      -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_TV=1          \
#      ../alive2-install
#    ninja
#    cd ../..
#
#    mkdir -p build
#    cd build
#    cmake -DALIVE2_SOURCE_DIR=../tmp/alive2   \
#          -DALIVE2_BUILD_DIR=../alive2/build  \
#          -DCMAKE_PREFIX_PATH=../llvm/build   \
#          -DCMAKE_EXPORT_COMPILE_COMMANDS=1   \
#          -DCMAKE_BUILD_TYPE=RelWithDebInfo   \
#          -G Ninja                            \
#           ./minotaur
#    ninja
#
#  '';
#  
#  installPhase = ''
#    mkdir -p $out/bin
#    mkdir -p $out/lib
#    
#    cache-dump          $out/bin
#    cache-infer         $out/bin
#    get-cost            $out/bin
#    infer-cut.sh        $out/bin
#    libconfig.a         $out/lib
#    libcost.a           $out/lib
#    libslice.a          $out/lib
#    libsynthesizer.a    $out/lib
#    libutils.a          $out/lib
#    minotaur-c++        $out/bin
#    minotaur-cc         $out/bin
#    minotaur-cs         $out/bin
#    minotaur-slice      $out/bin
#    online.so           $out/bin
#    slice-c++           $out/bin
#    slice-cc            $out/bin
#  '';
#  
#  meta = {
#    description = "A Synthesizing Superoptimizer for LLVM";
#    homepage = "https://github.com/minotaur-toolkit/minotaur"; 
#  };
#}
