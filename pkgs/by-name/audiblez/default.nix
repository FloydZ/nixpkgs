{ lib 
, fetchgit
, python3
, python3Packages
, fetchPypi
, espeak
, ffmpeg
, poetry
}:
let 
  inherit (python3Packages) buildPythonPackage setuptools;
  bs4 = buildPythonPackage rec {
    pname = "bs4";
    version = "0.0.2";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-pIaFxY9Q/hJ3IkF7roP+a631ANVLVffjn/5Dt5hlOSU=";
    };

    nativeBuildInputs = with python3Packages; [
      hatchling
      beautifulsoup4
    ];
  };

 misaki = buildPythonPackage rec {
    pname = "misaki";
    version = "0.7.10";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      # for 0.9.4 
      #sha256 = "sha256-OWD6Pm3heakO6OYoRGpKT2uMcwtuNBCZnPOWGJ9NnEA=";
      sha256 = "sha256-VFe7gp6LiGeMeIvXar/8zhV0fLtzRDtzQZJJ9j3YyRs=";
    };

    nativeBuildInputs = with python3Packages; [
      hatchling
      addict
      regex
      scipy
    ];
  };

  kokoro = buildPythonPackage rec {
    pname = "kokoro";
    version = "0.7.9";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      # for 0.9.4 
      # sha256 = "sha256-+/YzJieX+M9G/awzFc+creZ9yLdiwP7M8zSJJ3L7msQ=";
      sha256 = "sha256-YrMkIriYUwPXwOMKJGWUWsiWoQcNAeTNW9j5X5vUxz8=";
    };
    nativeBuildInputs = with python3Packages; [
      hatchling
      loguru
      numpy_1
      scipy
      torch
      transformers
      huggingface-hub
      misaki
    ];
  };
in
python3.pkgs.buildPythonApplication rec {
  pname = "audiblez";
  version = "v0.9.13";
  pyproject = true;

  src = fetchgit {
    url = "https://github.com/santinic/audiblez";
    rev = "ef74c1bb15df208781c20ce66191e3f1a82cf4d8";
    sha256 = "sha256-LrwV5OFK+gHgB1djrmVJGb6wSp0x3YGC4MSNegBRj0g=";
  };
  doCheck = false;
  nativeBuildInputs = with python3Packages; [
    setuptools

    # external binaries
    espeak
    ffmpeg
    poetry

    # python packages
    poetry-core
    ebooklib
    pick
    soundfile
    spacy
    tabulate
    kokoro
    misaki
    bs4
  ];

  buildInputs = with python3Packages; [ 
  ];
  
  meta = with lib; {
    description = " Generate audiobooks from e-books ";
    homepage = "https://github.com/santinic/audiblez";
    license = licenses.mit;
  };
}
