{ lib
, fetchFromGitHub
, docker
, buildGoModule
}:
buildGoModule {
  name = "sandbox-mcp";

  # Source from GitHub. This pulls the latest commit from main;
  # change `rev`/`sha256` if you want a release instead.
  src = fetchFromGitHub {
    owner = "pottekkat";
    repo = "sandbox-mcp";
    rev = "v0.1.1";
    sha256 = "sha256-4Di296hHFnLdAask3XdmZzWMonHmqBspcZwpw5cjIbQ=";
  };

  vendorHash = "sha256-h5eKKlD3nz/XdjT8AJVTC0cg1Axh30qWimYVW7LmweE=";
  modRoot = "./";

  nativeBuildInputs = [
  ];

  # For building/testing Dockerfile if needed
  buildInputs = [
    docker
  ];


  # Minimal runtime dependencies declaration (Docker)
  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ ];
  };
}
