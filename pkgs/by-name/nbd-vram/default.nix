{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  addDriverRunpath,
  bash,
  coreutils,
  util-linux,
  nbd,
  kmod,
  procps,
  systemd,
}:

let
  # Everything the helper scripts shell out to.
  runtimePath = lib.makeBinPath [
    coreutils # cat, basename, rm, touch
    util-linux # mkswap, swapon, swapoff
    nbd # nbd-client
    kmod # modprobe
    procps # sysctl
    systemd # systemctl (sleep / power-check helpers)
  ];
in
stdenv.mkDerivation {
  pname = "nbd-vram";
  version = "0-unstable-2026-07-17";

  src = fetchFromGitHub {
    owner = "c0deJedi";
    repo = "nbd-vram";
    rev = "e2f1144f93c6f508b01a2ff435509e27853c0632";
    hash = "sha256-c9u4GQLTJdY7ZPjHvYeoWJ8hE/us9aaWBsoJSYNzf30=";
  };

  nativeBuildInputs = [
    makeWrapper
    addDriverRunpath
  ];

  # For patchShebangs on the installed #!/bin/bash and #!/bin/sh scripts.
  buildInputs = [ bash ];

  postPatch = ''
    # Use the stdenv compiler instead of a hardcoded gcc.
    substituteInPlace Makefile --replace-fail "gcc " '$(CC) '

    # The disconnect script resets sysctls to hardcoded values on stop. Make it
    # skippable and let the NixOS module pass the values to restore.
    substituteInPlace nbd-vram-disconnect.sh --replace-fail \
      'sysctl -w vm.swappiness=60 vm.min_free_kbytes=65536 2>/dev/null || true' \
      '[ "''${VRAM_TUNE_VM:-1}" = 1 ] && sysctl -w vm.swappiness="''${VRAM_RESTORE_SWAPPINESS:-60}" vm.min_free_kbytes="''${VRAM_RESTORE_MIN_FREE_KBYTES:-65536}" 2>/dev/null || true'
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 nbd-vram $out/bin/nbd-vram

    for s in connect disconnect sleep power-check; do
      install -Dm755 nbd-vram-$s.sh $out/libexec/nbd-vram/nbd-vram-$s
      wrapProgram $out/libexec/nbd-vram/nbd-vram-$s --prefix PATH : ${runtimePath}
    done

    install -Dm644 nbd-vram.conf $out/share/nbd-vram/nbd-vram.conf
    install -Dm644 README.md $out/share/doc/nbd-vram/README.md

    runHook postInstall
  '';

  # The daemon dlopen()s libcuda.so.1; on NixOS it lives in /run/opengl-driver/lib.
  postFixup = ''
    addDriverRunpath $out/bin/nbd-vram
  '';

  meta = {
    description = "Use an NVIDIA GPU's VRAM as swap space via NBD + CUDA";
    homepage = "https://github.com/c0deJedi/nbd-vram";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "nbd-vram";
  };
}
