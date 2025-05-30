{ pkgs
, lib
, stdenv
, buildBazelPackage
, fetchgit
, fetchFromGitHub
, bazel_7
, gcc
, libcap
, elfutils
}:
let
  system = stdenv.hostPlatform.system;
  registry = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "bazel-central-registry";
    #rev = "1c729c2775715fd98f0f948a512eb173213250da";
    #hash = "sha256-1iaDDM8/v8KCOUjPgLUtZVta7rMzwlIK//cCoLUrb/s=";
    rev = "d647d422c17b6e894e0840b869580b8a6b220744";
    hash = "sha256-G5Ij/TmypKHm5fKRQ/3jsi4r2rvtDTnGdzUX/OH7jRQ=";
  };
  rulesCC = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "rules_cc";
    #rev = "5c1be25800e0806356624c1effd7a23240b3a45e";
    #hash = "sha256-VbTjcPm7+sc+Ii16Y6lDwSJYkuMlNKDFCaU9+4zNWug=";
    rev = "3a357794d21169dba8704655c500622982cbb1a2";
    hash = "sha256-G5Ij/TmypKHm5fKRQ/3jsi4r2rvtDTnGdzUX/OH7jRQ=";
  };
in
buildBazelPackage rec {
  name = "perf_data_converter";
  pname = "perf_data_converter";
  bazel = bazel_7;
  
  src = fetchgit {
    url = "https://github.com/google/perf_data_converter/";
    rev = "530879f5c78623048982761008d2466f898a4649";
    sha256 = "sha256-eiRqdJlCN6U0Ln9CRveMJK7EJvf2qv7PRn1X65ATrRE=";
  };
  
  fetchConfigured = false; 
  fetchAttrs = {
    sha256 = {
      aarch64-linux = "";
      x86_64-linux  = "sha256-xaCNVMM78GTleRO7LcGaRBRfQZATj3tWWwiXiXx+QKM=";
    }.${system} or (throw "No hash for system: ${system}");
  };

  buildInputs = with pkgs; [ 
    gcc
    git 
    libcap
    elfutils
  ];
  
  #removeRulesCC = true;
  #removeLocalConfigCc = true;
  #removeLocal = false;
  bazelTargets = [ "src:perf_to_profile" ];
  bazelBuildFlags = [
    "-c opt"
  ];
  bazelFlags = [
    "--registry" "file://${registry}"
    "--override_repository=rules_cc=${rulesCC}"

  ];
  buildAttrs = {
    installPhase = ''
      mkdir -p $out/bin
      cp -r bazel-bin/src/perf_to_profile $out/bin
    '';
  };
  meta = {
    description = "Tool to convert Linux perf files to the profile.proto format used by pprof";
    homepage = "https://github.com/google/perf_data_converter"; 
  };
}
