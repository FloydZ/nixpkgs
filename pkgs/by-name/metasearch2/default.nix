{ pkgs
, lib
, stdenv
, fetchgit
, rustPlatform
, callPackage}:
rustPlatform.buildRustPackage rec {
  pname = "metasearch2";
  version = "0.0.1";

  src = fetchgit {
    url = "https://github.com/mat-1/metasearch2";
    rev = "cad5db8072bdbc8b5b26fe7eca96304d54598caf";
    sha256 = "sha256-IRflQI4fqFUYDoZHl2r+2mhqphonX+CU4TyDdcBWsGo=";
  };
  
  doCheck = false;
  cargoHash = "";
  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  buildInputs = with pkgs; [ 
    clang
  ];

  meta = with lib; {
    description = "a cute metasearch engine ";
    homepage = "https://github.com/mat-1/metasearch2";
    license = licenses.unlicense;
  };
}
