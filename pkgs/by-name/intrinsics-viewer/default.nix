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
    rev = "465095a51d7b21286385db9f8d41ce1ef52381f3";
    sha256 = "sha256-L4CTUaZPo9C1iXnyb3CIYXL/xTRStKwakI0+oj0oksE=";
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
    hash = "sha256-xnpr/3l6hFAtR4/HY2nK+OeinIOpWXFaJu85paqMFaI=";
  };
  arm_operations = fetchurl {
    url = "https://developer.arm.com/architectures/instruction-sets/intrinsics/data/operations.json";
    hash = "sha256-b9Bhr800/+2x3OJ5PzzXCQ8w/jI+agXlR/yYVYkQTsY=";
  };
  rvv_intrinsics = fetchurl {
    url = "https://github.com/dzaima/rvv-intrinsic-doc/releases/download/v10/rvv-intrinsics-v10.json";
    hash = "sha256-gzbmuMvEw46zXZGXQV60Or+P4hgP+xj0XSFDpuSqb8o=";
  };
  v_spec = fetchurl {
    url = "https://github.com/dzaima/riscv-v-spec/releases/download/v1/v-spec.html";
    hash = "sha256-bjhQsqdhuaCpZFqKzAc3kM7Hhzb0RdKzU5+PVo0gvPE=";
  };
  v_crypto = fetchurl {
    url = "https://github.com/dzaima/riscv-v-spec/releases/download/v1/riscv-crypto-spec-vector.html";
    hash = "sha256-2AKSNEhGSr4VMUd/BurRa+Qqh1xn6yQushbBE6Hz5/o=";
  };
  wasm = fetchurl {
    url = "https://github.com/dzaima/dzaima.github.io/releases/download/wasm-v1/wasm-1.json";
    hash = "sha256-Q01DsA1ENOpDdRmPrbDO7UjQefTXR2CD0vlWZaLfR7I=";
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
    mkdir -p $out/bin
    mkdir -p $out/bin/data

    cp -r $src/* $out/bin
    cp intrinsics-viewer $out/bin

    cp ${intel_perf2} $out/bin/data/intel_perf2-1.js
    cp ${intel_intrinsics} $out/bin/data/intel_intrinsics-2.xml
    cp ${arm_intrinsics} $out/bin/data/arm_intrinsics-1.json
    cp ${arm_operations} $out/bin/data/arm_operations-1.json
    cp ${rvv_intrinsics} $out/bin/data/rvv-intrinsics-v10.json
    cp ${v_spec} $out/bin/data/v-spec.html
    cp ${v_crypto} $out/bin/data/riscv-crypto-spec-vector.html
    cp ${wasm} $out/bin/data/wasm-1.json.html
    '';
  
  meta = {
    description = " x86-64, ARM, and RVV intrinsics viewer ";
    homepage = "dzaima.github.io/intrinsics-viewer"; 
  };
}
