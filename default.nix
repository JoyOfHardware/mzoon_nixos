{ pkgs ? import <nixpkgs> {}, src ? ./. }:

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
      };

      src = src;

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
