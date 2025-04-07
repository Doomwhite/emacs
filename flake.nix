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
        # Define Emacs with Tree-sitter grammars
        emacsWithTreesit = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs: [
          epkgs.treesit-grammars.with-all-grammars
        ]);
        # Get the path to the Tree-sitter grammars
        treesitGrammarsPath = "${pkgs.emacsPackages.treesit-grammars.with-all-grammars}/lib";
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            emacsWithTreesit
            ripgrep
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

            # Set TREE_SITTER_DIR to the actual grammars location
            export TREE_SITTER_DIR=${treesitGrammarsPath}
            # Optionally, inform Emacs about the grammars path
            export EMACS_TREESIT_PATH=${treesitGrammarsPath}
          '';
        };
      });
}
