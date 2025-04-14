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
        lib = pkgs.lib;
        # Define Emacs with Tree-sitter grammars
        emacsWithTreesit = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs: [
          epkgs.treesit-grammars.with-all-grammars
        ]);
        # Get the path to the Tree-sitter grammars
        treesitGrammarsPath = "${pkgs.emacsPackages.treesit-grammars.with-all-grammars}/lib";
        # Custom derivation wrapping emacsWithTreesit using runCommand
        customEmacs =
          pkgs.runCommand "custom-emacs" {
            nativeBuildInputs = [pkgs.makeWrapper];
            buildInputs =
              [emacsWithTreesit]
              ++ (with pkgs; [
                ripgrep
                cmake
                gnumake
                libtool
                rustup
                gcc
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
            ln -s ${emacsWithTreesit}/bin/ctags $out/bin/ctags
            ln -s ${emacsWithTreesit}/bin/ebrowse $out/bin/ebrowse
            ln -s ${emacsWithTreesit}/bin/emacs-30.1 $out/bin/emacs-30.1
            ln -s ${emacsWithTreesit}/bin/emacsclient $out/bin/emacsclient
            ln -s ${emacsWithTreesit}/bin/etags $out/bin/etags

            # Wrap the emacs binary with environment variables
            wrapProgram $out/bin/emacs \
              --set TREE_SITTER_DIR "${treesitGrammarsPath}" \
              --set EMACS_TREESIT_PATH "${treesitGrammarsPath}" \
              --prefix PATH : ${lib.makeBinPath [
                pkgs.ripgrep
                pkgs.gnumake
                pkgs.cmake
                pkgs.libtool
                pkgs.rustup
                pkgs.gcc
                pkgs.cargo
                pkgs.zls
                pkgs.nodejs
                pkgs.nodePackages.typescript
                pkgs.nodePackages.typescript-language-server
                pkgs.nodePackages."@angular/cli"
              ]}

            wrapProgram $out/bin/emacsclient \
              --set TREE_SITTER_DIR "${treesitGrammarsPath}" \
              --set EMACS_TREESIT_PATH "${treesitGrammarsPath}" \
              --prefix PATH : ${lib.makeBinPath [
                pkgs.ripgrep
                pkgs.gnumake
                pkgs.cmake
                pkgs.libtool
                pkgs.rustup
                pkgs.gcc
                pkgs.cargo
                pkgs.zls
                pkgs.nodejs
                pkgs.nodePackages.typescript
                pkgs.nodePackages.typescript-language-server
                pkgs.nodePackages."@angular/cli"
              ]}

            ln -s ${emacsWithTreesit}/share $out/share
          '';
      in {
        # Use customEmacs as the default package
        packages.default = customEmacs;
        apps.default = {
          type = "app";
          program = "${customEmacs}/bin/emacs";
        };
        devShells.default = pkgs.mkShell {
          buildInputs = [customEmacs];
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
