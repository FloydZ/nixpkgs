self: super:

let
  llvmVersion = "23.0.0";
  llvmMajor = "23";

  llvmMonorepoSrc = super.fetchgit {
    url = "https://github.com/llvm/llvm-project.git";
    rev = "llvmorg-23-init";
    sha256 = "sha256-SnymXzpN9dwWdPoAeevXNEd3K4e2ABGQ/E/ai5Cz7Pc=";
  };

in rec {
  llvmPackages_23 = super.llvmPackages_git.override {
    version = llvmVersion;
    monorepoSrc = llvmMonorepoSrc;
    llvmAttrs = {
      # Ensure major version matches
      version = llvmVersion;
      release_version = llvmVersion;
      majorVersion = llvmMajor;
    };
  };
}
