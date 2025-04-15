{ lib
, stdenv
, fetchgit
, cmake
, abseil-cpp
, pkg-config
, boost
, grpc
, protobuf_21
, capstone
, libGL
, libGLU
, qt5
, libssh2
, vulkan-volk
, vulkan-headers
, vulkan-validation-layers
, gtest
, python3
, clang_15
, llvm_15
, clang
, git
}:
stdenv.mkDerivation rec {
  name = "orbit";
  pname = "orbit";
  version = "1.0.2";
  
  src = fetchgit {
    url = "https://github.com/google/orbit/";
    rev = "eb93af556ef91f6f69d98a5a12f1dd4a8b60d376";
    sha256 = "sha256-XJSa8Y8HC4aVqMW3TATi+gIS7uInc4pWvOUzYYD/ch4=";
  };

  patches = [ 
    ../cmake.patch
  ];
  
  enableParallelBuilding = true;
  # hiredis="${customHiredis}";
  
  buildInputs = [
    # customLLVM
    clang
    clang_15
    llvm_15
    abseil-cpp
    pkg-config
    boost
    grpc 
    protobuf_21
    capstone
    libssh2
    vulkan-volk
    vulkan-headers
    vulkan-validation-layers
    python3
    cmake
    gtest
    git
  ];

  nativeBuildInputs = [ 
    libGL 
    libGLU
    qt5.qtbase
  ];

  dontWrapQtApps = true;
  cmakeFlags = [
    "-DWITH_VULKAN=OFF"
    "-DCMAKE_C_COMPILER=clang"
    "-DCMAKE_CXX_COMPILER=clang++"
    "-DCMAKE_C_FLAGS=-Wno-error"
    "-DCMAKE_CXX_FLAGS=-Wno-error"
  ];

  # QT_QPA_PLATFORM_PLUGIN_PATH="${qt5.qtbase.bin}/lib/qt-${qt5.qtbase.version}/plugins/platforms";
  # configurePhase = '' '';
  # installPhase = '' '';
  
  meta = {
    description = "C/C++ Performance Profiler ";
    homepage = "https://github.com/google/orbit"; 
  };
}
