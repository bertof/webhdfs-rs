{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = { url = "github:numtide/flake-utils"; inputs.nixpkgs.follows = "nixpkgs"; };
    rust-overlay = { url = "github:oxalica/rust-overlay"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:

    let
      cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
      dockerImageNamePrefix = "repository.v2.moon-cloud.eu:4567/mind-foods-hub/api-and-connectors";
      overlays = [
        rust-overlay.overlays.default # Rust overlay lib
        (self: super: { rustc = super.rust-bin.nightly."2022-07-21".default; }) # Rust overlay
      ];

      multiPlatform = flake-utils.lib.eachDefaultSystem
        (system:
          let
            # Packages
            pkgs = import nixpkgs { inherit system overlays; };

            # Rust packages
            rustPackages = import ./Cargo.nix {
              inherit pkgs; buildRustCrateForPkgs = customBuildRustCrateForPkgs;
            };
            customBuildRustCrateForPkgs = pkgs: pkgs.buildRustCrate.override {
              defaultCrateOverrides = pkgs.defaultCrateOverrides // {
                # odbc = attrs: {
                #   nativeBuildInputs = [ pkgs.pkg-config ];
                #   buildInputs = [ pkgs.unixODBC ];
                #   extraLinkFlags = [ "-L${pkgs.unixODBC.out}/lib" ];
                # };
              };
            };
          in
          with pkgs.lib;
          rec {

            devShells = {
              default = pkgs.mkShell {
                venvDir = "./.venv";
                buildInputs = with pkgs; [
                  stdenv.cc.cc.lib
                  # rustEnvironment
                  # cargo
                  rustc
                  pkg-config
                  openssl.dev

                  bacon
                  cargo-watch
                  cargo-outdated
                  clippy
                  crate2nix
                  rustfmt
                ];
              };
            };
          });

      linuxOnly =
        flake-utils.lib.eachSystem [ "x86_64-linux" ]
          (system:
            let
              pkgs = import nixpkgs { inherit system overlays; };
            in
            {
              packages = { };
            });
    in
    nixpkgs.lib.recursiveUpdate
      multiPlatform
      linuxOnly;

}
