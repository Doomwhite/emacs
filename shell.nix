{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # Define the packages you want in the shell
  buildInputs = with pkgs; [
    emacs       # Emacs editor
    cmake       # CMake build system
    libtool     # Libtool for building shared libraries
    nodejs      # Node.js, which includes npm
  ];

  # Shell hook to set up the environment
  shellHook = ''
    # Create a local directory for global npm packages
    export NPM_GLOBAL_DIR=$PWD/.npm-global
    mkdir -p $NPM_GLOBAL_DIR

    # Configure npm to use this directory for global installs
    npm config set prefix $NPM_GLOBAL_DIR

    # Add the npm global bin directory to PATH
    export PATH=$NPM_GLOBAL_DIR/bin:$PATH

    # Install the required npm packages globally
    npm install -g typescript typescript-language-server

    # Print a message to confirm the shell is ready
    echo "Nix shell with Emacs, CMake, Libtool, Node.js, and LSPs is ready!"
  '';
}
