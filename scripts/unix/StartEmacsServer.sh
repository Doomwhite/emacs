#!/bin/bash

# Function to check if Emacs is running
check_emacs_running() {
  if pgrep -x "emacs" > /dev/null; then
    echo "Killing Emacs process..."
    pkill -f "emacs"
    echo "Emacs process killed."
  else
    echo "No Emacs process found to kill."
  fi
}

# Function to delete Emacs server files if they exist
delete_emacs_server_files() {
  echo "Deleting Emacs server files..."
  if [ -d "$HOME/.emacs.d/server" ]; then
    rm -rf "$HOME/.emacs.d/server/*"
    echo "Emacs server files deleted."
  else
    echo "No Emacs server files found to delete."
  fi
}

# Function to start the Emacs daemon
start_emacs_daemon() {
  echo "Starting Emacs daemon..."
  runemacs --daemon --chdir "$HOME" > /dev/null 2>&1
  echo "Emacs daemon started."
}

# Function to check if the Emacs server is ready
check_server_ready() {
  echo "Checking if Emacs server is ready..."

  while true; do
    if [ -d "$HOME/.emacs.d/server" ] && [ "$(ls -A "$HOME/.emacs.d/server")" ]; then
      echo "Emacs server is ready."
      break
    else
      sleep 1
    fi
  done
}

# Function to run emacsclient
run_emacsclient() {
  echo "Running emacsclient..."
  emacsclient -c -n
}

# Main execution starts here
check_emacs_running
delete_emacs_server_files
start_emacs_daemon
check_server_ready

# Check if an optional argument is passed
if [ "$1" == "run-client" ]; then
  run_emacsclient
fi
