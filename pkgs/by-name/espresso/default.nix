{ lib
, stdenv
, callPackage
, fetchgit
, gnumake
, asciidoctor
}:
stdenv.mkDerivation{
  name = "Quine_McCluskey";
  pname = "Quine_McCluskey";
  version = "v2.1.1";
  
  src = fetchgit {
    url = "https://github.com/classabbyamp/espresso-logic/";
    rev = "85265139e9598852f9388d293658a1977a829a01";
    sha256 = "sha256-qgq+9Z3zYLXakJ0CQtF6eF8tL26CB6UTto/L3ZuqRdk=";

    #url = "https://github.com/chipsalliance/espresso/";
    #rev = "549eb5c8ed7f699693441cf18c7655f732a203dc";
    #sha256 = "sha256-w4Yjruxn7UZXX+Uwt9BnKSsw4JQwwjz383ODj6LuDng=";
  };

  patches = [ ./opt.patch ];

  nativeBuildInputs = [ 
    gnumake
    asciidoctor
  ];

  buildPhase = ''
    cd espresso-src
    make
    cd ..
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/espresso $out/bin
  '';
  
  meta = {
    description = "";
    homepage = "https://github.com/chipsalliance/"; 
  };
}
