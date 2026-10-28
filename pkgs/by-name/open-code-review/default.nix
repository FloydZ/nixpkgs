{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
  installShellFiles,
  makeWrapper,
  versionCheckHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "open-code-review";
  version = "1.13.3";

  src = fetchFromGitHub {
    owner = "alibaba";
    repo = "open-code-review";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dDKNxjI0pWoJGabUvsGTERYKvKtvEm3UGD/FLPKpfnw=";
  };

  vendorHash = "sha256-LpqnNp6gxHatHH68pM59ESQICDDSVrkZm7AJLVvYTao=";

  # Upstream pins a patch-level toolchain (currently `go 1.26.9`) that is often
  # newer than the one in nixpkgs. Go patch releases are bugfix-only, so rewrite
  # the directive to the exact version we ship -- otherwise the build tries to
  # download a toolchain, which the sandbox forbids.
  #
  # The patch level must be kept: truncating this to `go 1.26` makes `go mod
  # vendor` demand a `go mod tidy`, because a directive without a patch level
  # changes which requirements go.mod has to state explicitly.
  postPatch = ''
    sed -i -E 's/^go [0-9]+\.[0-9]+(\.[0-9]+)?$/go ${go.version}/' go.mod
  '';

  subPackages = [ "cmd/opencodereview" ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=v${finalAttrs.version}"
    "-X=main.GitCommit=v${finalAttrs.version}"
    # Pinned rather than stamped with the current date, to keep builds reproducible.
    "-X=main.BuildDate=1970-01-01T00:00:00Z"
  ];

  # The test suite shells out to `git` against throwaway repos and reaches for
  # the network in the LLM/provider packages, so only vet-style checks are safe
  # here. `subPackages` already limits the build to the CLI itself.
  doCheck = false;

  postInstall = ''
    # Upstream's npm launcher exposes the binary as `ocr`; the Go build names it
    # `opencodereview`. Ship both so docs and muscle memory keep working.
    ln -s opencodereview "$out/bin/ocr"

    # Telemetry is opt-in upstream (it only activates on OCR_ENABLE_TELEMETRY=1),
    # but set both switches to 0 explicitly so the default stays off even if that
    # changes. --set-default keeps an operator's own export authoritative.
    wrapProgram "$out/bin/opencodereview" \
      --set-default OCR_ENABLE_TELEMETRY 0 \
      --set-default OCR_CONTENT_LOGGING 0

    installShellCompletion --cmd ocr \
      --bash <("$out/bin/opencodereview" completion bash) \
      --fish <("$out/bin/opencodereview" completion fish) \
      --zsh  <("$out/bin/opencodereview" completion zsh)
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AI-powered code review CLI that reviews git diffs with a configurable LLM";
    homepage = "https://github.com/alibaba/open-code-review";
    changelog = "https://github.com/alibaba/open-code-review/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "ocr";
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
