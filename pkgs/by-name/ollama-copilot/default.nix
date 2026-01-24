{ lib
, fetchFromGitHub
, docker
, buildGoModule
}:
buildGoModule {
  name = "ollama-copilot";
  src = fetchFromGitHub {
    owner = "josuemontano";
    repo = "ollama-copilot";
    rev = "9109dec92189106c7963878af7e95bc1ec06b705";
    sha256 = "sha256-w8Dcyst7BkDldZqszNliUkyY6affrx2xV5SW+SLcQLw=";
  };

  vendorHash = "sha256-cRJEPuWLsgBFZyatkHN+J02LNzx306Ctt7zuCGY3CUM=";
  modRoot = "./";

  nativeBuildInputs = [
  ];

  # For building/testing Dockerfile if needed
  buildInputs = [
    docker
  ];


  # Minimal runtime dependencies declaration (Docker)
  meta = with lib; {
    description = "Proxy that allows you to use ollama as a copilot like Github copilot ";
    homepage = "https://github.com/josuemontano/ollama-copilot";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ ];
  };
}
