{ lib
, stdenv
, fetchgit
, fetchurl
, python3
}:

stdenv.mkDerivation rec {
  name = "intrinsics-viewer";
  version = "0.0.1";
  
  src = fetchgit {
    url = "https://github.com/dzaima/intrinsics-viewer";
    rev = "d6b2f113f5d60aab7a846e1a530b9670bda293cd";
    sha256 = "sha256-oogjyWQjcHTw7c3kXNO9PEp02X9Z+3VCsvyinBePNfk=";
  };

  # different sources for intrinsics
  intel_perf2 = fetchurl {
    url = "https://www.intel.com/content/dam/develop/public/us/en/include/intrinsics-guide/perf2.js";
    hash = "sha256-swbpTZF+oW7iPwo5gjnW3/KyvYKEZVfZcBuwSiJoQQ0=";
  };
  intel_intrinsics = fetchurl {
    url = "https://www.intel.com/content/dam/develop/public/us/en/include/intrinsics-guide/data-3-6-9.xml";
    hash = "sha256-BIskMNc8Pr9Rj6BndJ1hnA+G46wdUDcvaoOCGloYr/E=";
  };
  arm_intrinsics = fetchurl {
    url = "https://developer.arm.com/architectures/instruction-sets/intrinsics/data/intrinsics.json";
    hash = "sha256-PuzwyH6clfVOUBis2kNnC+g5NfW03Cib0FR8pbB5k+U=";
  };
  arm_operations = fetchurl {
    url = "https://developer.arm.com/architectures/instruction-sets/intrinsics/data/operations.json";
    hash = "sha256-b9Bhr800/+2x3OJ5PzzXCQ8w/jI+agXlR/yYVYkQTsY=";
  };
  rvv_base = fetchurl {
    url = "https://github.com/dzaima/rvv-intrinsic-doc/releases/download/v7/rvv_base.json";
    hash = "sha256-oY+xY8bU2EbW4+sVmcV9ZktPGAzXN19aXqkdFqzZwXY=";
  };
  v_spec = fetchurl {
    url = "https://github.com/dzaima/riscv-v-spec/releases/download/v1/v-spec.html";
    hash = "sha256-bjhQsqdhuaCpZFqKzAc3kM7Hhzb0RdKzU5+PVo0gvPE=";
  };
  nativeBuildInputs = [ 
    python3
  ];

  # do not do anything
  buildPhase = ''echo "nothing to build" '';
  configPhase = '' '';

  patches = [
   ./executable.patch
  ];
  installPhase = ''
    ls -R .
    mkdir -p $out/bin
    mkdir -p $out/bin/data

    cp -r $src/* $out/bin
    cp intrinsics-viewer $out/bin

    cp ${intel_perf2} $out/bin/data/intel_perf2-1.js
    cp ${intel_intrinsics} $out/bin/data/intel_intrinsics-1.xml
    cp ${arm_intrinsics} $out/bin/data/arm_intrinsics-1.json
    cp ${arm_operations} $out/bin/data/arm_operations-1.json
    cp ${rvv_base} $out/bin/data/rvv_base-5.json
    cp ${v_spec} $out/bin/data/v-spec.html
    '';
  
  meta = {
    description = " x86-64, ARM, and RVV intrinsics viewer ";
    homepage = "dzaima.github.io/intrinsics-viewer"; 
  };
}
