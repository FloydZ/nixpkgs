{ lib
, stdenv
, fetchgit
, callPackage
, z3_4_12, klee, hiredis, cmake
#needed for llvm
, llvmPackages_17
, gtest
}:
let
  # z3_4_12 = z3_4_12.overrideAttrs (oldAttrs: rec {
  #   src = fetchgit {
  #     url = "https://github.com/Z3Prover/z3.git";
  #     rev = "z3-4.12.2";
  #     sha256 = "sha256-DTgpKEG/LtCGZDnicYvbxG//JMLv25VHn/NaF307JYA=";
  #   };
  # });

  # we only need the source 
  customKLEE_src = fetchgit {
    url = "https://github.com/regehr/klee.git";
    rev = "klee-for-souper-17-2";
    sha256 = "sha256-I/+rrRchEGxOGGrGvJv1+0ryQH356rjy88GL3NyLlho=";
  };

  customAlive2 =  callPackage ./../alive2/default.nix { };
  customAlive2_src = fetchgit {
    # v7
    #url = "https://github.com/manasij7479/alive2/";
    #rev = "c003606d9cb013453f7352b0ca25d22d73148685";
    #hash = "sha256-F9GcDEuMQE42GUFdUFU5SA4tmRDYc7ChOQpBK1j+hVc=";

    # v4
    url = "https://github.com/manasij7479/alive2/";
    rev = "v4";
    hash = "sha256-GdNVU+pzOb8J0Mvq8yUVwPsUPqKOvn/2RfqoRrzfvPk=";
  };


  #customLLVM = llvmPackages_17.llvm.overrideAttrs (oldAttrs: rec {
  #  src = fetchgit {
  #    url = "https://github.com/regehr/llvm-project.git";
  #    rev = "disable-peepholes-llvmorg-17.0.3-1";
  #    sha256 = "sha256-3nokr6MLhCySlJmmRNvPXFm3scKHgOjucFCFhHof+HU=";
  #  };
  #});

  customLLVM = llvmPackages_17.llvm.overrideAttrs (oldAttrs: rec {
    patches = oldAttrs.patches ++ [ ./llvm_souper.patch ];
    doCheck = false;
  });

  customHiredis = hiredis.overrideAttrs (oldAttrs: rec {
    src = fetchgit {
      url = "https://github.com/redis/hiredis.git";
      rev = "869f3d0ef1513dd0258ad7190c9914df16dcc4a4";
      sha256 = "sha256-9YeoAquVa+GSyzaZMJ2iI3M20HUXshJ3zjGEnRoYTuc=";
    };
  });
in
stdenv.mkDerivation rec {
  name = "souper";
  pname = "souper";
  version = "0.1.0";
  
  src = fetchgit {
    url = "https://github.com/google/souper";
    rev = "a4fed064aee8f172f6e8c9e5569cb7429ff03a80";
    sha256 = "sha256-OVHLJwNWmgvCAe1DbHFDzWP/NRBcG3ojELPz5I0na+M=";
  };

  patches = [
    ./souper.patch
  ];
  
  enableParallelBuilding = true;
  z3="${z3_4_12}";
  alive2="${customAlive2}";
  klee="${customKLEE_src}";
  llvm="${customLLVM}";
  hiredis="${customHiredis}";
  
  buildInputs = [
    # customLLVM
    llvmPackages_17.bintools
    llvmPackages_17.llvm
    alive2
    z3_4_12
    hiredis
    gtest
  ];

  nativeBuildInputs = [ 
    customLLVM
    z3_4_12
    hiredis
    gtest
    cmake
  ];

  configurePhase = ''
    #mkdir -pv third_party/llvm-release-install/lib
    #cp -r ${llvm} third_party/llvm-release-install
    #cp -r ${customLLVM.lib}/lib/* third_party/llvm-release-install
    #ls -R third_party/llvm-release-install


    # prepare alive
    mkdir -pv third_party/alive2-build
    cp -r ${customAlive2_src} third_party/alive2 
    cp -r ${customAlive2}/lib/* third_party/alive2-build

    # prepare Z3 
    mkdir -pv third_party/z3-install
    cp -r ${z3_4_12}/bin third_party/z3-install
    cp -r ${z3_4_12.lib}/* third_party/z3-install

    # prepare hiredis
    mkdir -pv third_party/hiredis-install/include/hiredis
    mkdir -pv third_party/hiredis-install/lib
    cp -r ${customHiredis.src} third_party/hiredis
    cp -r ${customHiredis.out}/lib/* third_party/hiredis-install/lib
    cd third_party/hiredis
    cp -r alloc.h hiredis.h async.h read.h sds.h adapters ../hiredis-install/include/hiredis 
    cd ../..

    mkdir -pv third_party/klee
    cp -r ${customKLEE_src}/* third_party/klee

    mkdir -p build
    cd build
    cmake .. -DLLVM_CXXFLAGS="$(llvm-config --cppflags) -fno-exceptions -fno-rtti -Wno-deprecated-enum-enum-conversion" -DLLVM_LIBS="$(llvm-config --libs) $(llvm-config --system-libs)" -DLLVM_LDFLAGS="$(llvm-config --ldflags)" -DCMAKE_SKIP_BUILD_RPATH=ON
  '';
  
  #buildPhase = ''
  #'';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib

    ls -R .

    cp sclang $out/bin
    cp sclang++ $out/bin
    cp souper $out/bin
    cp souper-check $out/bin
    cp souper-check-gdb.py $out/bin
    cp souper-interpret $out/bin
    cp souper2llvm $out/bin
    cp cache_dfa $out/bin
    cp cache_dump $out/bin
    cp cache_import $out/bin
    cp cache_infer $out/bin
    cp count-insts $out/bin
    cp reduce $out/bin
    cp run_lit $out/bin
    cp redis-unix-socket.conf $out/bin

    cp libsouperPassProfileAll.so $out/lib
    cp libsouperPassProfileAll.so $out/lib
    cp libprofileRuntime.a $out/lib
    cp libsouperCodegen.a $out/lib
    cp libsouperExtractor.a $out/lib
    cp libsouperInfer.a $out/lib
    cp libsouperInst.a $out/lib
    cp libsouperKVStore.a $out/lib
    cp libsouperParser.a $out/lib
    cp libsouperPass.so $out/lib
    cp libsouperSMTLIB2.a $out/lib
    cp libsouperTool.a $out/lib
    cp libkleeExpr.a  $out/lib

    cp -r ${z3_4_12.lib}/lib/* $out/bin
    cp -r ${customHiredis.out}/lib/* $out/bin
  '';
  
  meta = {
    description = "A superoptimizer for LLVM IR";
    homepage = "https://github.com/google/souper"; 
  };
}
