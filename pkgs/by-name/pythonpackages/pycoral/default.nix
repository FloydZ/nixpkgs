# source: https://discourse.nixos.org/t/importerror-libswresample-d02fa90a-so-4-7-100-cannot-open-shared-object-file/28337
{ stdenv, lib, python38Packages, fetchFromGitHub,fetchPypi, fetchurl
}:
python38Packages.buildPythonPackage rec {
  pname = "pycoral";
  version = "v2.0.0";
  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "pycoral";
    rev = "${version}";
    sha256 = "sha256-1lmdxd6B/FwXBLe7HWEhTSP2dWVEVQJGKScwXINfsFo==";
  };

  patches = [
    ./pycoral_runtime.patch
  ];
  doCheck = false;
  nativeBuildInputs = [
    python38Packages.setuptools
    python38Packages.wheel
  ];
  propagatedBuildInputs = [
    (
      python38Packages.buildPythonPackage rec {
        pname = "tflite-runtime";
        version = "2.7.0";
        format = "wheel";
        #src = fetchPypi rec {
        #  inherit pname version format;
        #  dist = pkgs.python38;
        #  sha256 = "sha256-wlsXhSf2W4VonkR5WUZQC8phIUiRNew/0V6C7y3yrbI=";
        #};

        #src = fetchurl rec {
        #  url = "https://files.pythonhosted.org/packages/00/59/0f0fe355e7cc0438e029fef831512d38c54ffcf35a4a7190c2303ec1e567/tflite_runtime-2.5.0-cp38-cp38-linux_armv7l.whl";
        #  sha256 = "sha256-lT9rfipmecOble95V6a9eP/0teDdeCRFmc+ngDfhmVM=";
        #};
        # 2.7.0
        src = fetchurl rec {
          url = "https://files.pythonhosted.org/packages/b3/2c/7b4daafab5d45db8719e7a287b84e21e9f07908b8359e54406fb2fce9292/tflite_runtime-2.7.0-cp38-cp38-manylinux2014_aarch64.whl";
          sha256 = "sha256-wlsXhSf2W4VonkR5WUZQC8phIUiRNew/0V6C7y3yrbI=";
        };
        
        # 2.14.0
        #src = fetchurl rec {
        #  url = "https://files.pythonhosted.org/packages/d4/8c/c07940377eb20c1e9de1aa3bae9e68618bb2f35bce026a113539c8ce75dd/tflite_runtime-2.14.0-cp38-cp38-manylinux_2_34_aarch64.whl";
        #  sha256 = "sha256-Q3Fn/j2LEvUPXWlNqPRdJoq4SkleJMPdgQ4C4QEhJd4=";
        #};

        propagatedBuildInputs = [
          python38Packages.numpy
        ];
      }
    )
    # h3py compile error
    #pkgs.python38Packages.tensorflow
    python38Packages.numpy
    python38Packages.pillow
  ];
}
