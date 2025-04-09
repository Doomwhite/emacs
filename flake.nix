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
        packages = {
          inherit emacsWithTreesit;
        };
        devShells.default = pkgs.mkShell {
          buildInputs = [ emacsWithTreesit ];
          shellHook = ''
            export TREE_SITTER_DIR=${treesitGrammarsPath}
            export EMACS_TREESIT_PATH=${treesitGrammarsPath}
          '';
        };
      });
}
