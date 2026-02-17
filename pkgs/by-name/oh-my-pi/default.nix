{
  lib,
  buildNpmPackage,
  fetchNpmDeps,
  fetchFromGitHub,
  pkg-config,
  node-gyp,
  python3,
  pixman,
  cairo,
  pango,
  libpng,
  giflib,
}:

buildNpmPackage rec {
  pname = "can1357";
  version = "12.9.0";

  src = fetchFromGitHub {
    owner = "can1357";
    repo = "oh-my-pi";
    tag = "v${version}";
    hash = "sha256-75W6GjyEK7IzKyH1uqKr06a7fwnFuNOEE2jFhy2KE80=";
  };


  npmDepsHash = "";
  # npmDeps = fetchNpmDeps {
  #   inherit src;
  #   name = "${pname}-${version}-npm-deps-patched";
  #   hash = npmDepsHash;
  #   patches = [ ./0004-fix-deps-v080.patch ];
  # };

  nativeBuildInputs = [
    pkg-config
    node-gyp
    python3
    pixman
    cairo
    pango
    libpng
    giflib
  ];

  buildInputs = [
    python3
    pixman
    cairo
    pango
    libpng
  ];

  # required for sharp
  makeCacheWritable = true;
  npmBuildScript = "production";
  meta = {
    description = "Agent Orchestration Command Center";
    homepage = "https://github.com/RunMaestro/Maestro";
    license = lib.licenses.mit;
  };
}
