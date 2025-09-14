{ stdenv
, lib
, python3Packages
, fetchFromGitHub
, fetchgit
}:
python3Packages.buildPythonPackage rec {
  pname = "slothy";
  version = "v01.5.0";
  format = "pyproject";
  src = fetchFromGitHub {
    owner = "slothy-optimizer";
    repo = "slothy";
    rev = "${version}";
    sha256 = "sha256-ftYDUxp1Ue5epLOpcHrNmhenaE17f+mvXX+gKNU/MpY=";
  };

  patches = [
  ];
  doCheck = false;
  nativeBuildInputs = [
    python3Packages.setuptools
    python3Packages.wheel
  ];
  propagatedBuildInputs = [
    python3Packages.numpy
    python3Packages.pillow

    python3Packages.sympy
    python3Packages.ortools
    python3Packages.protobuf
    python3Packages.unicorn
  ];
}
