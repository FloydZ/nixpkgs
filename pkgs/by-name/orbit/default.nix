{ lib
, stdenv
, fetchgit
, callPackage
, cmake
, abseil-cpp
, pkg-config
, boost
, grpc
, protobuf_21
, capstone
, libGL
, libGLU
, qtbase
# , qmake
, libssh2
, vulkan-volk
, vulkan-headers
, vulkan-validation-layers
, gtest
, python3
, clang_15
, llvm_15
}:
let
  #customHiredis = hiredis.overrideAttrs (oldAttrs: rec {
  #  src = fetchgit {
  #    url = "https://github.com/redis/hiredis.git";
  #    rev = "19cfd60d92da1fdb958568cdd7d36264ab14e666";
  #    sha256 = "sha256-1ujX/h/ytBGnLbae/vry8jXz6TiTLKs9l9l+qGO/cVo=";
  #  };
  #});
in
stdenv.mkDerivation rec {
  name = "orbit";
  pname = "orbit";
  version = "1.0.2";
  
  src = fetchgit {
    url = "https://github.com/google/orbit/";
    rev = "eb93af556ef91f6f69d98a5a12f1dd4a8b60d376";
    sha256 = "";
  };

  patches = [
    ./souper.patch
  ];
  
  enableParallelBuilding = true;
  # hiredis="${customHiredis}";
  
  buildInputs = [
    # customLLVM
    clang_15
    llvm_15
    abseil-cpp
    pkg-config
    boost
    grpc 
    protobuf_21
    capstone
    qtbase
    libssh2
    vulkan-volk
    vulkan-headers
    vulkan-validation-layers
    python3
    cmake
    gtest
  ];

  nativeBuildInputs = [ 
    clang_15
    libGL 
    libGLU

  ];

  WITH_VULKAN="OFF";
  # configurePhase = '' '';
  # installPhase = '' '';
  
  meta = {
    description = "C/C++ Performance Profiler ";
    homepage = "https://github.com/google/orbit"; 
  };
}
