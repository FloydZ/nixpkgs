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
    rev = "1c729c2775715fd98f0f948a512eb173213250da";
    hash = "sha256-1iaDDM8/v8KCOUjPgLUtZVta7rMzwlIK//cCoLUrb/s=";
  };
  rulesCC = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "rules_cc";
    rev = "5c1be25800e0806356624c1effd7a23240b3a45e";
    hash = "sha256-VbTjcPm7+sc+Ii16Y6lDwSJYkuMlNKDFCaU9+4zNWug=";
  };
in
buildBazelPackage rec {
  name = "perf_data_converter";
  pname = "perf_data_converter";
  bazel = bazel_7;
  
  src = fetchgit {
    url = "https://github.com/google/perf_data_converter/";
    rev = "cf4fe87ba200220e0c10740592ddadeef32064cd";
    sha256 = "sha256-NQiwQeJz3D0Dqvk4eZhm69Cxwxx1dM8MP2WfUzmvXtE=";
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
