# Sheprd: a native GPUI client for an existing local Herdr daemon.
# Ported from the upstream flake (https://github.com/sheprd-labs/sheprd), Linux only.
#
# Usable as `pkgs.callPackage ./default.nix { }` or `nix-build default.nix`.
{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;

  version = "20261118.1";

  src = pkgs.fetchFromGitHub {
    owner = "sheprd-labs";
    repo = "sheprd";
    tag = "v${version}";
    hash = "sha256-rOkJdM+vykbS7DleoXocfGKQ/A0qp1ekmHPXSbYPgZM=";
  };

  # Upstream pins its Rust toolchain in rust-toolchain.toml, and it is newer
  # than the rustc in nixpkgs, so take it from rust-overlay (same revision as
  # upstream's flake.lock).
  rust-overlay = fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/74cebce67ef6671ea48fda353a5be2d229bd2920.tar.gz";
    sha256 = "001vnhr0ckw19da6j22205j5khw6nh36m7bf9ql3bp01zji9813l";
  };
  toolchain = (pkgs.extend (import rust-overlay)).rust-bin.fromRustupToolchainFile "${src}/rust-toolchain.toml";
  rustPlatform = pkgs.makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  };

  # Loaded with dlopen at runtime, so the linker never records them.
  runtimeLibraries = [
    pkgs.vulkan-loader
    pkgs.wayland
  ];
in
rustPlatform.buildRustPackage {
  pname = "sheprd";
  inherit version src;

  cargoHash = "sha256-JVxWooAkcOvqtbSeOg7LXy3Q8lviDiVPTU+CO+Q/i4U=";

  # The app starts chats with the sheprd-acp beside its executable, runs
  # sheprd-remote-control beside it as a user service, runs automations in
  # sheprd-automate, and starts sheprd-nearby for Bluetooth pairing/presence.
  cargoBuildFlags = [
    "-p"
    "sheprd-gpui"
    "-p"
    "sheprd-acp"
    "-p"
    "sheprd-remote-control"
    "-p"
    "sheprd-automate"
    "-p"
    "sheprd-nearby"
  ];

  # The rest of the workspace suite needs a desktop or a live daemon.
  cargoTestFlags = [
    "-p"
    "sheprd-gpui"
    "--test"
    "cli"
  ];

  nativeBuildInputs = [
    pkgs.pkg-config
    rustPlatform.bindgenHook
    pkgs.makeWrapper
  ];

  buildInputs = [
    pkgs.alsa-lib
    pkgs.fontconfig
    pkgs.freetype
    pkgs.libxkbcommon
    pkgs.libxcb
  ]
  ++ runtimeLibraries;

  # No updater key is embedded, so this build never tries to replace itself.
  postInstall = ''
    install -Dm644 scripts/release/org.sheprd.Sheprd.desktop \
      $out/share/applications/org.sheprd.Sheprd.desktop
    install -Dm644 assets/icons/sheprd-linux.svg \
      $out/share/icons/hicolor/scalable/apps/sheprd.svg
  '';

  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath runtimeLibraries} $out/bin/sheprd
    wrapProgram $out/bin/sheprd \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.wl-clipboard
          pkgs.xclip
        ]
      }
    # Legacy names, pointing at the final wrapper.
    ln -s sheprd $out/bin/herdr-gpui
    for helper in acp automate nearby remote-control; do
      ln -s "sheprd-$helper" "$out/bin/herdr-$helper"
    done
  '';

  meta = {
    description = "Native GPUI client for an existing local Herdr daemon";
    homepage = "https://sheprd.org";
    license = lib.licenses.asl20;
    mainProgram = "sheprd";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
