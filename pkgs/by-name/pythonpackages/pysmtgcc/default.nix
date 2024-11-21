{ stdenv, lib, python3Packages, fetchFromGitHub,
}:
python3Packages.buildPythonPackage rec {
  pname = "pysmtgcc";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "kristerw";
    repo = "pysmtgcc";
    rev = "01a029a01ac004e38a098edf4238aeec81928aaf";
    sha256 = "sha256-tHgvMp2wGkBQXrHrgg6zonm8mOT+TMjS6AxV3+O1rto=";
  };

  doCheck = false;
  nativeBuildInputs = [
    python3Packages.setuptools
    python3Packages.wheel
  ];
}
