{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    rust-overlay.url = "github:oxalica/rust-overlay";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs {
          localSystem = system;
          overlays = [
            inputs.rust-overlay.overlays.default
            (final: prev: {
              my-rust = prev.rust-bin.nightly."2024-06-24".default.override {
                extensions = [
                  "rust-src" # for rust-analyzer
                ];
                targets = [
                  "wasm32-unknown-unknown"
                  "x86_64-unknown-linux-gnu"
                ];
              };

              mzoon = prev.callPackage (
                {
                  stdenv,
                  pkg-config,
                  my-rust,
                  binaryen,
                  wasm-bindgen-cli,
                  rustPlatform,
                  openssl,
                }:
                let
                  bindgen-cli = wasm-bindgen-cli.override {
                    version = "0.2.92"; # This needs to match the wasm-bindgen version of zoon https://github.com/MoonZoon/MoonZoon/blob/main/crates/zoon/Cargo.toml
                    hash = "sha256-1VwY8vQy7soKEgbki4LD+v259751kKxSxmo/gqE6yV0=";
                    cargoHash = "sha256-aACJ+lYNEU8FFBs158G1/JG8sc6Rq080PeKCMnwdpH0=";
                  };
                in
                stdenv.mkDerivation {
                  pname = "moonzoon";
                  version = "0.1.0";

                  cargoDeps = pkgs.rustPlatform.importCargoLock {
                    lockFile = ./Cargo.lock;
                    allowBuiltinFetchGit = true;
                  };

                  src = inputs.self;

                  nativeBuildInputs = [
                    pkg-config
                    my-rust
                    binaryen
                    bindgen-cli
                    rustPlatform.cargoBuildHook
                    rustPlatform.cargoInstallHook
                    rustPlatform.cargoSetupHook
                  ];

                  buildInputs = [
                    openssl
                  ];

                  doCheck = true;

                  cargoBuildType = "release";

                  cargoBuildFlags = [
                    "-p"
                    "mzoon"
                  ];

                  passthru = {
                    rust = my-rust;
                    inherit bindgen-cli;
                  };
                }
              ) { };
            })
          ];
        };
      in
      {
        packages = {
          default = inputs.self.packages."${system}".mzoon;
          mzoon = pkgs.mzoon;
        };

        devShells.default =
          with pkgs;
          mkShell {
            inputsFrom = [ mzoon ];
          };
      }
    );
}
