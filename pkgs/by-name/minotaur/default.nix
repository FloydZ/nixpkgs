{ lib
, stdenv
, fetchgit
, callPackage
, z3
, cmake
, ninja
, git
, llvmPackages
, re2c
, redis
, hiredis
, gtest
, python3
}:
let
  #customAlive2 =  callPackage ./../alive2/default.nix { };
  cAlive2 = fetchgit {
    url = "https://github.com/alivetoolkit/alive2/";
    rev = "v21.0";
    hash = "sha256-LL6/Epn6iHQJGKb8PX+U6zvXK/WTlvOIJPr6JuGRsSU=";
  };

  cLLVM = fetchgit {
      url = "https://github.com/llvm/llvm-project.git";
      rev = "llvmorg-21.1.8";
      sha256 = "sha256-pgd8g9Yfvp7abjCCKSmIn1smAROjqtfZaJkaUkBSKW0=";
  };
  #cLLVM = llvmPackages.llvm.overrideAttrs (oldAttrs: rec {
  #  src = fetchgit {
  #    url = "https://github.com/llvm/llvm-project.git";
  #    rev = "llvmorg-21.1.8";
  #    sha256 = "sha256-pgd8g9Yfvp7abjCCKSmIn1smAROjqtfZaJkaUkBSKW0=";
  #  };
  #});

  cZ3 = z3.overrideAttrs (oldAttrs: rec {
    src = fetchgit {
      url = "https://github.com/Z3Prover/z3.git";
      rev = "z3-4.15.4";
      sha256 = "sha256-eyF3ELv81xEgh9Km0Ehwos87e4VJ82cfsp53RCAtuTo=";
    };
  });
in
stdenv.mkDerivation rec {
  name = "minotaur";
  pname = "minotaur";
  version = "0.1.0";
  
  src = fetchgit {
    url = "https://github.com/minotaur-toolkit/minotaur";
    rev = "866204d727313a15209976d833316b3b3e779110";
    sha256 = "sha256-eSiOChsJ/eQ6SNCKlh6/kUslgNEylGjLBK4z/l7/tBY=";
  };

  #enableParallelBuilding = true;

  z3="${cZ3}";
  alive2="${cAlive2}";
  llvm="${cLLVM}";
  
  buildInputs = [
    cLLVM
    cmake
    ninja 
    git
    re2c
    redis
    hiredis
    gtest
    python3
  ];

  nativeBuildInputs = [ 
  ];

  configurePhase = ''
    # prepare Z3 
    ls -al
    mkdir -pv tmp/z3
    mkdir -pv tmp/z3/build
    mkdir -pv tmp/z3-install
    cp -r ${cZ3.src}/* tmp/z3 
    cd tmp/z3
    ls -al
    cmake -S ./ -B ./build -G Ninja  \
      -DCMAKE_BUILD_TYPE=Release              \
      -DCMAKE_INSTALL_PREFIX=tmp/z3-install   \
      -DZ3_BUILD_TEST_EXECUTABLES=OFF         \
      -DZ3_BUILD_EXECUTABLE=OFF
    cmake --build ./build --target install
    cd ../..

    # prepare llvm
    mkdir -pv tmp/llvm
    mkdir -pv tmp/llvm/build
    mkdir -pv tmp/llvm-install
    cp -r ${cLLVM}/* tmp/llvm
    cd tmp/llvm
    git apply ../../llvm-main-minotaur.patch
    cmake -G Ninja -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_EH=ON    \
      -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release         \
      -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_ASSERTIONS=ON   \
      -DLLVM_ENABLE_PROJECTS="llvm;clang"                       \
      ../llvm-install 
    ninja
    cd ../..

    # prepare alive
    mkdir -pv tmp/alive2
    mkdir -pv tmp/alive2/build
    mkdir -pv tmp/alive2-install
    cd tmp/alive2
    cp -r ${cAlive2}/* tmp/alive2
    cmake -G Ninja -DLLVM_DIR=$HOME/llvm/build/lib/cmake/llvm \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_TV=1          \
      ../alive2-install
    ninja
    cd ../..

    mkdir -p build
    cd build
    cmake -DALIVE2_SOURCE_DIR=../tmp/alive2   \
          -DALIVE2_BUILD_DIR=../alive2/build  \
          -DCMAKE_PREFIX_PATH=../llvm/build   \
          -DCMAKE_EXPORT_COMPILE_COMMANDS=1   \
          -DCMAKE_BUILD_TYPE=RelWithDebInfo   \
          -G Ninja                            \
           ./minotaur
    ninja

  '';
  
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    
    cache-dump          $out/bin
    cache-infer         $out/bin
    get-cost            $out/bin
    infer-cut.sh        $out/bin
    libconfig.a         $out/lib
    libcost.a           $out/lib
    libslice.a          $out/lib
    libsynthesizer.a    $out/lib
    libutils.a          $out/lib
    minotaur-c++        $out/bin
    minotaur-cc         $out/bin
    minotaur-cs         $out/bin
    minotaur-slice      $out/bin
    online.so           $out/bin
    slice-c++           $out/bin
    slice-cc            $out/bin
  '';
  
  meta = {
    description = "A Synthesizing Superoptimizer for LLVM";
    homepage = "https://github.com/minotaur-toolkit/minotaur"; 
  };
}
