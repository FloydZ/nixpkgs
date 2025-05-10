{ lib 
, fetchFromGitHub
, fetchgit
, python3
, python3Packages
}:

let
  inherit (python3Packages) buildPythonPackage setuptools;

  # Shared source for all RFL subpackages
  rflSrc = fetchFromGitHub {
    owner = "rackslab";
    repo = "RFL";
    rev = "v1.4.0";
    hash = "sha256-8Qu5Cay48Y3fZy/nmG/aYrsFxUX5jdwGVUFmkE8Y4wY=";
  };

  rfl-core = buildPythonPackage {
    pname = "RFL-core";
    version = "v1.4.0";
    pyproject = true;
    src = "${rflSrc}/src/core";
    nativeBuildInputs = [ setuptools ];
  };

  rfl-authentication = buildPythonPackage {
    pname = "RFL-authentication";
    version = "v1.4.0";
    pyproject = true;
    src = "${rflSrc}/src/authentication";
    nativeBuildInputs = [
      setuptools 
    ];
    propagatedBuildInputs = with python3Packages; [
      rfl-core
      pyjwt
      python-ldap
    ];
  };

  rfl-settings = buildPythonPackage {
    pname = "RFL-authentication";
    version = "v1.4.0";
    pyproject = true;
    src = "${rflSrc}/src/authentication";
    nativeBuildInputs = [ setuptools ];
  };

  rfl-web = buildPythonPackage {
    pname = "RFL-authentication";
    version = "v1.4.0";
    pyproject = true;
    src = "${rflSrc}/src/authentication";
    nativeBuildInputs = [ setuptools ];
  };

  rfl-log = buildPythonPackage {
    pname = "RFL-log";
    version = "v1.4.0";
    pyproject = true;
    src = "${rflSrc}/src/log";
    nativeBuildInputs = [ setuptools ];
  };

in
python3.pkgs.buildPythonApplication rec {
  pname = "slurm-web";
  version = "v4.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rackslab";
    repo = "${pname}";
    rev = "refs/tags/${version}";
    hash = "sha256-YoKbF2QLElhWNQmBV3YDft1G6uHpLI21UXdNShJi+Z8=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
    flask
    requests
    rfl-core
    rfl-log
    rfl-authentication
    rfl-settings
    rfl-web

    prometheus-client
    aiohttp
    pytest
  ];

  buildInputs = [ 
  ];
  
  meta = with lib; {
    description = "Open source web interface for Slurm HPC & AI clusters";
    homepage = "slurm-web.com";
    license = licenses.mit;
    #maintainers = with maintainers; [ gjjvdburg ];
  };
}
