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
        # Custom derivation wrapping emacsWithTreesit using runCommand
        customEmacs = pkgs.runCommand "custom-emacs" {
          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = [ emacsWithTreesit ] ++ (with pkgs; [
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
        } ''
          echo "DEBUG: Running customEmacs build script" >&2
          # Set up the output directory
          mkdir -p $out/bin
          # Symlink the emacs binary
          ln -s ${emacsWithTreesit}/bin/emacs $out/bin/emacs
          # Create the haha file
          echo "TESTE" > $out/haha
          echo "DEBUG: Created $out/haha" >&2
          # Wrap the emacs binary with environment variables
          wrapProgram $out/bin/emacs \
            --set TREE_SITTER_DIR "${treesitGrammarsPath}" \
            --set EMACS_TREESIT_PATH "${treesitGrammarsPath}"
          echo "DEBUG: Wrapped $out/bin/emacs with environment variables" >&2
          ls -l $out >&2
          ls -l $out/bin >&2
        '';
      in {
        # Use customEmacs as the default package
        packages.default = customEmacs;
        devShells.default = pkgs.mkShell {
          buildInputs = [ customEmacs ];
          shellHook = ''
            echo "DEBUG: Setting up devShell" >&2
            export TREE_SITTER_DIR=${treesitGrammarsPath}
            export EMACS_TREESIT_PATH=${treesitGrammarsPath}
          '';
        };
        formatter = pkgs.alejandra;
      }
    );
}
