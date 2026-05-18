{ lib
, stdenv
, callPackage
, fetchFromGitHub
, cmake
, ninja
, git
, libunwind
, grpc
, pkg-config
, protobuf
, abseil-cpp
, re2
, c-ares
, openssl
, zlib
, llvmPackages_git
}:
let 
  #llvm = llvmPackages.llvm;
  llvm = llvmPackages_git.llvm.overrideAttrs (oldAttrs: rec {
    patches = oldAttrs.patches ++ [ 
      ./0001-MCAD-Patch-0-Add-identifier-field-to-mca-Instruction.patch
      ./0002-MCAD-Patch-2-WIP-Start-mapping-e500-itinerary-model-.patch
    ];
    patchFlags = [ "-p1" ];
    doCheck = false;
  });
in
stdenv.mkDerivation rec {
  pname = "llvm-mca-daemon";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "securesystemslab";
    repo = "LLVM-MCA-Daemon";
    rev = "10373aa4daeab1ebcc1529a15fc66cfc2688c156";
    sha256 = "sha256-RiG9AoAX7AI2BEp05WoLJvJp97D4whJQc9feNPj0Too=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    libunwind
    git
    pkg-config
    grpc
    llvm
  ];

  buildInputs = [
      llvm
    grpc
    protobuf
    abseil-cpp
    re2
    c-ares
    openssl
    zlib
    ];

postPatch = ''
  # 1. Remove FetchContent usage entirely
  sed -i '/include(FetchContent)/d' plugins/CMakeLists.txt
  sed -i '/FetchContent_Declare *( *grpc/,+20 d' plugins/CMakeLists.txt
  sed -i '/FetchContent_MakeAvailable *( *grpc *)/d' plugins/CMakeLists.txt

  # 2. Inject system dependency usage
  sed -i '1i find_package(Protobuf CONFIG REQUIRED)\nfind_package(gRPC CONFIG REQUIRED)\n' plugins/CMakeLists.txt

  # 3. Fix typical target usage if still referenced
  sed -i 's/grpc++/gRPC::grpc++/g' plugins/CMakeLists.txt
  sed -i 's/libprotobuf/protobuf::libprotobuf/g' plugins/CMakeLists.txt
'';

  checkPhase = ''
    cd build 
    ninja check
  '';

  installPhase = ''
      ls -R
    mkdir -p $out/bin
    mkdir -p $out/lib
    
    cp cache-dump          $out/bin
  '';

  meta = with lib; {
    description = "LLVM-MCA-Daemon";
    homepage = "https://github.com/securesystemslab/LLVM-MCA-Daemon";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux;
  };
}
