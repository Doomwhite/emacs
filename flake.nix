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
          # Set up the output directory
          mkdir -p $out/bin
          # Symlink the emacs binary
          ln -s ${emacsWithTreesit}/bin/emacs $out/bin/emacs

          # Wrap the emacs binary with environment variables
          wrapProgram $out/bin/emacs \
            --set TREE_SITTER_DIR "${treesitGrammarsPath}" \
            --set EMACS_TREESIT_PATH "${treesitGrammarsPath}" \
            --prefix PATH : "${pkgs.ripgrep}/bin" \
            --prefix PATH : "${pkgs.cmake}/bin" \
            --prefix PATH : "${pkgs.libtool}/bin" \
            --prefix PATH : "${pkgs.rustup}/bin" \
            --prefix PATH : "${pkgs.cargo}/bin" \
            --prefix PATH : "${pkgs.zls}/bin" \
            --prefix PATH : "${pkgs.nodejs}/bin" \
            --prefix PATH : "${pkgs.nodePackages.typescript}/bin" \
            --prefix PATH : "${pkgs.nodePackages.typescript-language-server}/bin" \
            --prefix PATH : "${pkgs.nodePackages."@angular/cli"}/bin"
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
