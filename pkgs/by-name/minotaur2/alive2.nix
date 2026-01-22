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
  llvmPackages_git,
  llvmPackages_21,
}:
let 
  # llvmPkgs = llvmPackages_git.override {
  #   config = {
  #     enableRtti = true;
  #     enableEh   = true;
  #   };
  # };
  # llvm = llvmPkgs.llvm.overrideAttrs (oldAttrs: rec {
  #   patches = oldAttrs.patches ++ [ ./llvm-main-minotaur.patch ];
  #   doCheck = false;
  # });


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
  #llvm = llvmPkgs.llvm;
in
clangStdenv.mkDerivation (finalAttrs: {
  pname = "alive2";
  version = "21.0";

  src = fetchFromGitHub {
    owner = "AliveToolkit";
    repo = "alive2";
    #tag = "v${finalAttrs.version}";
    #hash = "sha256-LL6/Epn6iHQJGKb8PX+U6zvXK/WTlvOIJPr6JuGRsSU=";
    rev = "10340555bb9a83689779144d76a9c48a44e8c022";
    hash = "sha256-g9g4o8mEOHV9WWss2mvp8RGgYLUd1aZgm65CiraeMWI=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    re2c
  ];
  buildInputs = [
    z3
    hiredis
    llvm
  ];
  strictDeps = true;

  CXXFLAGS = toString [
    "-I${llvm.dev}/include"
  ];
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '-Werror' "" \
      --replace-fail 'find_package(Git REQUIRED)' ""
  '';

  env = {
    ALIVE2_HOME = "$PWD";
    LLVM2_HOME = "${llvm}";
    LLVM2_BUILD = "$LLVM2_HOME/build";
  };

  cmakeFlags = [
    "-DBUILD_TV=1 "
    ];

  preBuild = ''
    mkdir -p build
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
    description = "Automatic verification of LLVM optimizations";
    homepage = "https://github.com/AliveToolkit/alive2";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ shogo ];
    teams = [ lib.teams.ngi ];
    mainProgram = "alive";
  };
})
