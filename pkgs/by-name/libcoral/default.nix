{ stdenv
, lib
, buildBazelPackage
, fetchFromGitHub
, bazel_5
, libusb1
, python3
, callPackage
, fetchgit
, git
, abseil-cpp
, flatbuffers
}:

let
  aarch64_flags = [ "CPU=aarch64" ];
  buildPlatform = stdenv.buildPlatform;
  hostPlatform = stdenv.hostPlatform;
  pythonEnv = python3.withPackages (ps: [ ps.setuptools ps.numpy ]);
  bazelDepsSha256ByBuildAndHost = {
    x86_64-linux = {
      x86_64-linux = "sha256-42Wn/y0T9lCzELgav0/jGeTWXArBoyEm0eOJRD8B5EM=";
      aarch64-linux = "TODO";
    };
    aarch64-linux = {
      aarch64-linux = "TODO";
    };
  };
  bazelHostConfigName.aarch64-linux = "elinux_aarch64";
  bazelDepsSha256ByHost =
    bazelDepsSha256ByBuildAndHost.${buildPlatform.system} or
      (throw "unsupported build system ${buildPlatform.system}");
  bazelDepsSha256 = bazelDepsSha256ByHost.${hostPlatform.system} or
  (throw "unsupported host system ${hostPlatform.system} with build system ${buildPlatform.system}");

  flatbuffers_1_12 = flatbuffers.overrideAttrs (oldAttrs: rec {
    version = "1.12.0";
    NIX_CFLAGS_COMPILE = "-Wno-error=class-memaccess -Wno-error=maybe-uninitialized";
    cmakeFlags = (oldAttrs.cmakeFlags or []) ++ ["-DFLATBUFFERS_BUILD_SHAREDLIB=ON"];
    NIX_CXXSTDLIB_COMPILE = "-std=c++17";
    configureFlags = (oldAttrs.configureFlags or []) ++ ["--enable-shared"];
    src = fetchFromGitHub {
      owner = "google";
      repo = "flatbuffers";
      rev = "v${version}";
      sha256 = "sha256-L1B5Y/c897Jg9fGwT2J3+vaXsZ+lfXnskp8Gto1p/Tg=";
    };
  });
  libedgetpu_src =  callPackage ./../libedgetpu/default.nix { };
in 
  buildBazelPackage rec {
  pname = "libcoral";
  version = "grouper";
  bazel = bazel_5;

  src = fetchgit {
    #owner = "google-coral";
    #repo = pname;
    #sha256 = "sha256-73hwItimf88Iqnb40lk4ul/PzmCNIfdt6Afi+xjNiBE=";
    url = "https://github.com/google-coral/libcoral";
    rev = "release-${version}";
    sha256 = "sha256-XI9Cb/1CGwVB7EuplqYRzc/wy0pw5QLbirDHbeZzjT4=";
  };

  patches = [
    ./c++.patch
  ];
  
  libedgetpu = "${libedgetpu_src}";
  fetchAttrs.sha256 = bazelDepsSha256;

  buildInputs = [
    libusb1
    abseil-cpp
    flatbuffers_1_12

    # needed for tensorflow
    #gcc
  ];

  nativeBuildInputs =  [
    flatbuffers_1_12
  ];

  NIX_CXXSTDLIB_COMPILE = "-std=c++17";
  PYTHON_BIN_PATH = pythonEnv.interpreter;
  CPU = "k8";

  bazelTargets = [ 
    #"//coral:bbox_test"
    #"//coral:error_reporter_test"
    #"//coral:inference_repeatability_test"
    #"//coral:inference_stress_test"
    #"//coral:model_loading_stress_test"
    #"//coral:multiple_tpus_inference_stress_test"
    #"//coral:segmentation_models_test"
    #"//coral:test_utils_test"
    #"//coral:tflite_utils_test"
    #"//coral/classification:adapter_test"
    #"//coral/classification:classification_models_test"
    #"//coral/classification:cocompiled_classification_models_test"
    #"//coral/classification:lstm_mnist_models_test"
    #"//coral/detection:adapter_test"
    #"//coral/detection:models_test"
    #"//coral/dmabuf:dmabuf_devboard_test"
    #"//coral/dmabuf:model_pipelining_dmabuf_devboard_test"
    #"//coral/learn:imprinting_engine_test"
    #"//coral/learn:utils_test"
    #"//coral/learn/backprop:layers_test"
    #"//coral/learn/backprop:multi_variate_normal_distribution_test"
    #"//coral/learn/backprop:softmax_regression_model_test"
    #"//coral/learn/backprop:test_utils_test"
    #"//coral/pipeline:detection_models_test"
    #"//coral/pipeline:models_test"
    #"//coral/pipeline:pipelined_model_runner_test"
    #"//coral/pipeline/internal:memory_pool_allocator_test"
    #"//coral/pipeline/internal:segment_runner_test"
    #"//coral/pose_estimation:bodypix_test"
    #"//coral/pose_estimation:movenet_test"
    #"//coral/pose_estimation:posenet_decoder_test"
    #"//coral/pose_estimation:posenet_test"
    #"//coral/tools:automl_model_append_rnn_link_test"
    #"//coral/tools:tflite_graph_util_test"
    #"//coral/tools/partitioner:parameter_count_based_partitioner_test"
    #"//coral/tools/partitioner:profiling_based_partitioner_ondevice_test"
    #"//coral/tools/partitioner:profiling_based_partitioner_test"
    #"//coral/tools/partitioner:utils_test"
    "//coral/tools:append_recurrent_links"
	"//coral/tools:join_tflite_models"
	"//coral/tools:multiple_tpus_performance_analysis"
	"//coral/tools:model_pipelining_performance_analysis"
    "//coral/tools/partitioner:partition_with_profiling"
  ];

  bazelBuildFlags = [
    "--compilation_mode=opt"
    "--cpu=${CPU}"
  ] ++ (lib.optionals stdenv.isAarch64 "--copt=-ffp-contract=off");

  dontAddBazelOpts = true;
  
  #fetchConfigured = true;
  #removeRulesCC = false;
  #removeLocalConfigCc = true;
  #removeLocal = false;
  buildAttrs = {
    installPhase = ''
      cp -r bazel-bin/* "$out"
    '';
  };

  meta = {
    description = "C++ API for ML inferencing and transfer-learning on Coral devices";
    homepage = "https://github.com/google/libcoral"; 
  };
}
