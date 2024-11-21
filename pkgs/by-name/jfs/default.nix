{ lib, stdenv, fetchgit, cmake, llvmPackages_6, z3, lit, fetchFromGitHub}:
let
  z3old = z3.overrideAttrs (final: prev: {
    src = fetchFromGitHub {
      owner = "Z3Prover";
      repo = "z3";
      # rev = "z3-4.6.0";
      # sha256 = "sha256-DTgpKEG/LtCGZDnicYvbxG//JMLv25VHn/NaF307JYA=";
      rev = "b0aaa4c6d7a739eb5e8e56a73e0486df46483222";
      sha256 = "sha256-DTgpKEG/LtCGZDnicYvbxG//JMLv25VHn/NaF307JYA=";
    };
  });
in
stdenv.mkDerivation rec {
  pname = "jfs";
  version = "0.0.1";

  src = fetchgit {
    url = "https://github.com/mc-imperial/jfs";
    rev = "d38b3685e878bf552da52b9410b53dd2adcfdfd1";
    sha256 = "sha256-ukyhmb4Qm/3YesebCVmswSwvBG5TuVywBmLxfp6IROU";
  };

  patches = [
    ./cmake.patch
  ];

  #dontFixCmake = true;
  nativeBuildInputs = [ cmake ];
  buildInputs = [ 
    llvmPackages_6.libllvm 
    llvmPackages_6.stdenv 
    llvmPackages_6.stdenv.cc 
    z3old 
    lit
  ];

  cmakeBuildType = "Release";
  cmakeFlags = [
    "-DZ3_DIR=${z3old.lib}"
    "-DZ3_LIBRARIES=z3"
    "-DZ3_C_INCLUDE_DIRS=${z3old.dev}"
    "-DLLVM_CLANG_CXX_TOOL=${llvmPackages_6.stdenv.cc}/bin/clang++"
    "-DCLANG_RUNTIME_DIR=${llvmPackages_6.clang-unwrapped}"
    "-DENABLE_JFS_ASSERTS=NO"
  ];
  
  installPhase = ''
  mkdir -p $out/bin
  mkdir -p $out/lib
  mkdir -p $out/dev
  cp ./bin/* $out/bin
  cp -r ./lib/* $out/lib
  cp -r ./include $out/dev
  '';

  meta = with lib; {
    description = "Constraint solver based on coverage-guided fuzzing ";
    homepage = "";
    license = licenses.unlicense;
  };
}
