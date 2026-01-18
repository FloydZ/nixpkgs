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
  llvmPackages_20,
}:
let 
  llvm = llvmPackages_20.override {
    config = {
      enableRtti = true;
      enableEh = true;
    };
    patches = [
      ./llvm-main-minotaur.patch
    ];
  };
in
clangStdenv.mkDerivation (finalAttrs: {
  pname = "alive2";
  version = "21.0";

  src = fetchFromGitHub {
    owner = "AliveToolkit";
    repo = "alive2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LL6/Epn6iHQJGKb8PX+U6zvXK/WTlvOIJPr6JuGRsSU=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    re2c
  ];
  buildInputs = [
    z3
    hiredis
    llvm.llvm
  ];
  strictDeps = true;

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '-Werror' "" \
      --replace-fail 'find_package(Git REQUIRED)' ""
  '';

  env = {
    ALIVE2_HOME = "$PWD";
    LLVM2_HOME = "${llvm.llvm}";
    LLVM2_BUILD = "$LLVM2_HOME/build";
  };

  preBuild = ''
    mkdir -p build
    '';

  cmakeFlags = [
    "-DBUILD_TV=1 "
  ];

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
