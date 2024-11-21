{ pkgs
, lib
, fetchgit
, fetchFromGitHub
, rustPlatform
, callPackage}:
let
  rustPlatform = callPackage ./rust-platform-nightly.nix {};
in (rustPlatform "2024-04-10").buildRustPackage rec {
  pname = "not-perf";
  version = "0.1.1";
  src = fetchFromGitHub {
    owner = "koute";
    repo = pname;
    rev = version;
    hash = "sha256-QAErGvWF5Ye5yGWlIXRaOC3y/AzS/nB8jQSFqQwPLGY=";
  };
  cargoHash = "sha256-/H06bH/SVFUblLmG8BdSH5j4b+1cqVqiH/nSNl2/a24=";

  # TODO somehow master is not building
  # src = fetchgit {
  #   url = "https://github.com/koute/not-perf/";
  #   rev = "10e7960d9e26379c46d68bcca2a1db387c34ddb7";
  #   sha256 = "sha256-xt8Y0GOtqmrL5SOHYrwJszkkIDO/1lLBwTJG7f4SAvk=";
  # };
  #cargoHash = "sha256-AMIHnQ5SVtthomju0AfGNRXTLMCHakBeGzt4bSAcZY0=";

  # buildInputs = with pkgs; [ ];

  meta = with lib; {
    description = " A sampling CPU profiler for Linux ";
    homepage = "https://github.com/koute/not-perf";
    license = licenses.unlicense;
  };
}
