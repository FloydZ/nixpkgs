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
  pname = "maestro";
  version = "0.14.5";

  src = fetchFromGitHub {
    owner = "RunMaestro";
    repo = "Maestro";
    tag = "v${version}";
    hash = "sha256-6DSmmi7cd9FtCSGs5r86bigZiq7WS7rl1K7xtX8oJkU=";
  };


  npmDepsHash = "sha256-1tOdBi6n6KC1/CkuWayrQWwHjU5nMXJgxawwz+SBzJY=";
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
