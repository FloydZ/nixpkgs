{ pkgs
, lib
, stdenv
, fetchgit
, rustPlatform
, callPackage}:
let
in rustPlatform.buildRustPackage rec {
  pname = "perf2perfetto";
  version = "0.0.1";

  src = fetchgit {
    url = "https://github.com/michoecho/perf2perfetto";
    rev = "0cc3f9e0cbc61358ab1af7d0f2d5a85125f1ae73";
    sha256 = "sha256-dreBzneqsrUfpvstpYuAVs5rP5mcPe6KhYhrCeyearQ=";
  };

  patches = [
    ./bindgen.patch
  ];

  cargoHash = "sha256-wMm5HIMYzXDQFpntxcCQTqzILx9y+K3LxPQgIRah4E0=";

  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  buildInputs = with pkgs; [ 
    clang
    libclang
    # linuxHeaders
    stdenv.cc.libc.linuxHeaders
  ];

  LIBCLANG_PATH = "/nix/store/hyig8wi4j2xkf2l3zwsws2hdkz86wgbn-clang-16.0.6-lib/lib";
  C_INCLUDE_PATH = "${stdenv.cc.libc.linuxHeaders}/include";

  meta = with lib; {
    description = " An intel PT trace converter from `perf.data` to Fuchsia trace format. ";
    homepage = "https://github.com/michoecho/perf2perfetto";
    license = licenses.unlicense;
  };
}
