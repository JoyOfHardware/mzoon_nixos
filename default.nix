{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage (
  {
    lib,
    stdenv,
    cargo,
    rustPlatform,
    openssl,
    pkg-config,
    git,
  }: let
    inherit (lib) optionalString;

  in
    stdenv.mkDerivation (self: {
      pname = "moonzoon";
      version = "0.1.0"; # Replace with the actual version or use cargoMeta.package.version if available

      cargoDeps = rustPlatform.importCargoLock {
        lockFile = ./Cargo.lock;
      #   outputHashes = {
      #    "lexical-6.0.0" = "sha256-hL3o3fbdfFqFxVwvim1VFyCIJ7VEs7sQjStsfi4oa8U=";
      #  };
      };

      src = ./.;

      doCheck = true;

      cargoBuildType = "release";

      cargoBuildFlags = ["-p" "mzoon"];

      nativeBuildInputs = [
        cargo
        git
        openssl
        pkg-config
      ];

      buildInputs = [
        rustPlatform.cargoBuildHook
        rustPlatform.cargoInstallHook
        rustPlatform.cargoSetupHook
      ];
    })
) {}
