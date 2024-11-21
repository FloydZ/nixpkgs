{ lib 
, fetchFromGitHub
, fetchgit
, python3
, pdftk
, ghostscript
, poppler
, xonsh
, python3Packages
}:
python3.pkgs.buildPythonApplication rec {
  pname = "paper2remarkable";
  version = "v0.9.13";
  pyproject = true;

  #src = fetchFromGitHub {
  #  owner = "GjjvdBurg";
  #  repo = "paper2remarkable";
  #  rev = "refs/tags/${version}";
  #  hash = "sha256-ZrPKKa/vl06QAjGr16ZzKF/DAByFHr6ze2WVOCa+wf8=";
  #};

  src = fetchgit {
    url = "https://github.com/GjjvdBurg/paper2remarkable/";
    rev = "5cdf0b0ba0f2c64ab068dc5af4392493ff046ecd";
    sha256 = "sha256-lH4EJ+HzBXFm30bc8qKUMhF27lEntsIal+uYjXVO35Q=";
  };
  doCheck = false;
  nativeBuildInputs = with python3Packages; [
    setuptools
    beautifulsoup4
    html2text
    lxml-html-clean
    markdown
    pdfplumber
    pikepdf
    pycryptodome
    pyyaml
    readability-lxml
    regex
    requests
    titlecase
    unidecode
    weasyprint
  ];

  buildInputs = [ 
    pdftk
    ghostscript
    poppler
    xonsh
  ];
  
  meta = with lib; {
    description = " Fetch an academic paper or web article and send it to the reMarkable tablet with a single command ";
    homepage = "https://github.com/GjjvdBurg/paper2remarkable";
    license = licenses.mit;
    maintainers = with maintainers; [ gjjvdburg ];
  };
}
