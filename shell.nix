with import <nixpkgs> {};
let
  # Import your custom nixpkgs overlay from GitHub
  myPkgs = import (pkgs.fetchFromGitHub {
    owner = "FloydZ";
    repo = "nixpkgs";
    rev = "9ccf8be";
    sha256 = "sha256-/EXYeJ1PCqa7Y8QhJiM5/4+9Sk378Qt95xit5/pwCng=";
  }) { inherit pkgs; };
in
stdenv.mkDerivation {
  name = "test";
  buildInputs = with pkgs; [
    # Standard development tools
    git
    curl
    wget
    
    # Your custom packages from this repo
    myPkgs.blaster
    myPkgs.nanobench
    myPkgs.shot
    
    # Python environment (since blaster is a Python app)
    python3
    python3Packages.pip
    python3Packages.virtualenv
  ];

  shellHook = ''
    echo "Development shell loaded!"
    echo "Available custom packages:"
    echo "  - blaster: Fast lattice reduction using segmentation and BLAS"
    echo "  - nanobench: Benchmarking library"
    echo "  - shot: Screenshot tool"
    echo ""
    echo "Run 'blaster --help' to get started with BLASter"
  '';
}
