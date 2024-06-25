{ pkgs ? import <nixpkgs> {} }:

let
  rustOverlay = import (builtins.fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/refs/heads/master.tar.gz";
  });
  overlayedPkgs = import pkgs.path {
    overlays = [ rustOverlay ];
  };
  rustNightlyVersion = "2024-03-04"; # Replace with the desired nightly version
in
overlayedPkgs.mkShell {
  buildInputs = [
    overlayedPkgs.rust-bin.nightly."${rustNightlyVersion}".default
    pkgs.wasm-bindgen-cli
    pkgs.binaryen
  ];

  shellHook = ''
    echo "Cargo nightly environment ready (version ${rustNightlyVersion})."
  '';
}
