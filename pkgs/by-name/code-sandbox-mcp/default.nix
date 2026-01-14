{ lib
, stdenv
, fetchFromGitHub
, go
, makeWrapper
, docker
, buildGoModule
}:
buildGoModule {
  name = "code-sandbox-mcp";

  # Source from GitHub. This pulls the latest commit from main;
  # change `rev`/`sha256` if you want a release instead.
  src = fetchFromGitHub {
    owner = "Automata-Labs-team";
    repo = "code-sandbox-mcp";
    rev = "v0.0.30";
    sha256 = "sha256-z3DrVSupSdD7avZPiae+JhaUh8np0n1kvY+4ZdH8KPs=";
  };

  vendorHash = "sha256-PJQ3iLyrKzSis3CNpAY6Wlb/tyUvHOV3whsfeXI4xsw=";
  modRoot = "src/code-sandbox-mcp";

  nativeBuildInputs = [
  ];

  # For building/testing Dockerfile if needed
  buildInputs = [
    docker
  ];


  # Minimal runtime dependencies declaration (Docker)
  meta = with lib; {
    description = "Secure MCP server for isolated code execution via Docker containers";
    homepage = "https://github.com/Automata-Labs-team/code-sandbox-mcp";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ ];
  };
}
