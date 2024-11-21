{ lib
, stdenv
, callPackage
, fetchgit
, ocaml
, opam
, dune_3
, zstd
, clang
, ocamlPackages
}:
stdenv.mkDerivation rec {
  name = "usuba";
  pname = "usuba";
  version = "v1.1";
  
  src = fetchgit {
    url = "https://github.com/usubalang/usuba";
    rev = "0bb4656ffa03f7f5521b095456c3b5a54a779784";
    sha256 = "sha256-TI/u6eaHP+B4G4UqTjfuvs063yZ/lpWHGT41I65dKyM=";
  };

  nativeBuildInputs = [ 
    clang
    zstd
  ];

  buildInputs = [
    ocaml
    opam
    dune_3
    ocamlPackages.menhir
    ocamlPackages.menhirLib
    ocamlPackages.sexplib
    ocamlPackages.alcotest
    ocamlPackages.ppx_sexp_conv
    ocamlPackages.ppx_inline_test
    ocamlPackages.ppx_deriving
  ];

  buildPhase = ''
    opam init
    opam exec -- ./configure
    opam exec -- dune build
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    ls -R

  '';
  
  meta = {
    description = "kek";
    homepage = "kek"; 
  };
}
