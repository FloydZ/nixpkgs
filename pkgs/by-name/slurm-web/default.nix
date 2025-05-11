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
    pname = "rfl-core";
    version = "v1.4.0";
    pyproject = true;
    src = "${rflSrc}/src/core";
    nativeBuildInputs = [ setuptools ];
  };

  rfl-authentication = buildPythonPackage {
    pname = "rfl-authentication";
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

  rfl-permissions = buildPythonPackage {
    pname = "rfl-permissions";
    version = "v1.4.0";
    pyproject = true;
    src = "${rflSrc}/src/permissions";
    nativeBuildInputs = [
      setuptools 
    ];
    propagatedBuildInputs = with python3Packages; [
      rfl-core
      rfl-authentication
      pyyaml
    ];
  };

  rfl-settings = buildPythonPackage {
    pname = "rfl-settings";
    version = "v1.4.0";
    pyproject = true;
    src = "${rflSrc}/src/settings";
    nativeBuildInputs = [ setuptools ];
    propagatedBuildInputs = with python3Packages; [
      rfl-core
      pyyaml
    ];
  };

  rfl-web = buildPythonPackage {
    pname = "rfl-web";
    version = "v1.4.0";
    pyproject = true;
    src = "${rflSrc}/src/web";
    nativeBuildInputs = [ setuptools ];
    propagatedBuildInputs = with python3Packages; [
      rfl-core
      rfl-permissions
      rfl-authentication
      flask
    ];
  };

  rfl-log = buildPythonPackage {
    pname = "RFL-log";
    version = "v1.4.0";
    pyproject = true;
    src = "${rflSrc}/src/log";
    nativeBuildInputs = [ setuptools ];
    propagatedBuildInputs = with python3Packages; [
      rfl-core
    ];
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
    rfl-core
    rfl-log
    rfl-authentication
    rfl-settings
    rfl-web

    pytest
  ];

  buildInputs = with python3Packages; [ 
    flask
    requests
    prometheus-client
    aiohttp
  ];
  
  meta = with lib; {
    description = "Open source web interface for Slurm HPC & AI clusters";
    homepage = "slurm-web.com";
    license = licenses.mit;
    #maintainers = with maintainers; [ gjjvdburg ];
  };
}
