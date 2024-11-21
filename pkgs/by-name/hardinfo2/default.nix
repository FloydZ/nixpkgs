{ stdenv
, lib
, fetchFromGitHub
, cmake
, gnumake
, libsoup_3
, gtk3
, zlib
, json-glib
, pkg-config
}:

let
in stdenv.mkDerivation rec {
  pname = "hardinfo2";
  version = "2.1.11";

  src = fetchFromGitHub {
    owner = "hardinfo2";
    repo = pname;
    rev = "eb9b61b8d0e00faabb98ebcfe67297a2f426e133";
    sha256 = "sha256-y6Lj1uDFDfg3X2IsmWja+Gr2KgKQQHNTCEnGWqJeG7Q=";
  };

  patches = [
    ./cmake.patch
  ];
  # preConfigure = ''
  #   substituteInPlace ./CMakeLists.txt --replace /etc/os-release /etc/static/os-release
  # '';

  buildInputs = [
    libsoup_3
    json-glib
    gtk3
    zlib
    pkg-config
  ];

  nativeBuildInputs = [
    cmake
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    ls -R

    cp *.so $out/lib
    cp hardinfo2 $out/bin

  '';
}
