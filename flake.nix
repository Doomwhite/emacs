{
  description = "Development environment with Emacs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        # Define Emacs with Tree-sitter grammars
        emacsWithTreesit = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs: [
          epkgs.treesit-grammars.with-all-grammars
        ]);
        # Get the path to the Tree-sitter grammars
        treesitGrammarsPath = "${pkgs.emacsPackages.treesit-grammars.with-all-grammars}/lib";
      in {
        packages.default = emacsWithTreesit.overrideAttrs (old: {
          buildInput =
            (old.buildInputs or [])
            ++ (with pkgs; [
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
            ]);

          postInstall =
            (old.postInstall or "")
            + ''
                echo "Running postInstall script" >&2
                echo "Output directory: $out" >&2
                export TREE_SITTER_DIR="${treesitGrammarsPath}"
                export EMACS_TREESIT_PATH="${treesitGrammarsPath}"
                echo "TESTE" > $out/haha
                echo "Created haha file at $out/haha" >&2
                echo "Created haha file at $out/testedevalor" >&2
                ls -l $out >&2
            '';
        });

        devShells.default = pkgs.mkShell {
          buildInputs = [emacsWithTreesit];
          shellHook = ''
            export TREE_SITTER_DIR=${treesitGrammarsPath}
            export EMACS_TREESIT_PATH=${treesitGrammarsPath}
          '';
        };
        formatter = pkgs.alejandra;
      }
    );
}
