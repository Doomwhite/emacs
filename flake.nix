{
  description = "Development environment with Emacs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          # Define the packages you want in the shell
          buildInputs = with pkgs; [
            emacs
            cmake
            libtool
            rustup
            cargo
            zls
            nodejs
            nodePackages.typescript
            nodePackages.typescript-language-server
            nodePackages."@angular/cli"
          ];

          shellHook = ''
            rustup toolchain install stable --profile default
            rustup component add rust-analyzer
          '';
        };
      });
}
