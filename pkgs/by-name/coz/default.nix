{ pkgs, lib, stdenv, fetchgit }:
let 
in
stdenv.mkDerivation {
  pname = "cox";
  version = "0.2.2";

  src = fetchgit {
    url = "https://github.com/plasma-umass/coz";
    rev = "4659e50e4237345cbd70459a14ee64699cee2893";
    sha256 = "sha256-ibH2P8+jCziEUhdNpJMx66yZMM/RyHc8cwIeaYjz+MQ=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    python3
  ];

  buildInputs = with pkgs; [
    pkg-config
    docutils
    libelfin
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    mkdir -p $out/dev
    cp $src/coz $out/bin/coz
    cp -r $src/include $out/dev
    cp libcoz/libcoz.so $out/lib
  '';
  
  meta = with lib; {
    description = " Coz: Causal Profiling ";
    homepage = "https://plasma-umass.org/coz/"; 
    # maintainers = [ maintainers.cmcdragonkai ];
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
