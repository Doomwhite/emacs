import time
import subprocess
import logging
import os
from dotenv import load_dotenv
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Load environment variables from .env file
load_dotenv()  # This will automatically load variables from a '.env' file

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,  # Set to DEBUG for detailed logs
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler()]
)

# Log the current environment variables
logging.debug("Current environment variables:")
for key, value in os.environ.items():
    logging.debug(f"{key}: {value}")

# Get the base folder (tmp) from environment variables
tmp_folder = os.getenv("TMP_PATH")
if tmp_folder is None:
    logging.error("Missing TMP_PATH environment variable.")
    exit(1)

# Define file-command mappings (with environment variable keys and their associated commands)
WATCHED_FILES = [
    {"env_var": "FILE1_PATH", "command": "runemacs --daemon"},
    {"env_var": "FILE2_PATH", "command": "emacsclientw -c -n"},
    {"env_var": "CREATE_NEW_FRAME_FILE_NAME", "command": "echo 'Create new frame action triggered'"}
]

# Construct full file paths and validate environment variables
files_with_full_paths = []
for watched_file in WATCHED_FILES:
    file_path = os.getenv(watched_file["env_var"])
    if file_path is None:
        logging.error(f"Missing environment variable: {watched_file['env_var']}")
        exit(1)

    full_path = os.path.join(tmp_folder, file_path)
    files_with_full_paths.append({"path": full_path, "command": watched_file["command"]})

# Log the final file paths and associated commands
for file_info in files_with_full_paths:
    logging.info(f"Monitoring {file_info['path']} with command: {file_info['command']}")

# Define the file-system event handler
class TmpFolderHandler(FileSystemEventHandler):
    def on_created(self, event):
        self.on_edited_event(event)

    def on_modified(self, event):
        self.on_edited_event(event)

    def on_edited_event(self, event):
        """Triggers on file creation, modification, and deletion."""
        try:
            if event.is_directory:
                logging.debug(f"Ignoring directory event: {event.src_path}")
                return  # Ignore directories

            file_path = event.src_path.replace("\\", "/")  # Normalize Windows paths
            logging.info(f"Detected {event.event_type} -> {file_path}")

            # Loop through the list of files and check if the modified file matches
            for watched_file in files_with_full_paths:
                normalized_file_path = watched_file["path"].replace("\\", "/")  # Normalize path with forward slashes
                normalized_detected_path = file_path.replace("\\", "/")  # Normalize the detected path

                logging.info(f"Comparing: {normalized_detected_path} to {normalized_file_path}")

                if normalized_detected_path == normalized_file_path:
                    logging.info(f"Matched file: {normalized_detected_path}. Executing associated command.")
                    self.execute_command(watched_file["command"], normalized_detected_path)
                    return  # Stop searching once a match is found

            logging.debug(f"File {file_path} is not in the WATCHED_FILES list.")
        except Exception as e:
            logging.error(f"Error handling event for {event.src_path}: {e}")

    def execute_command(self, command, file_path):
        """Executes the associated command for the modified file."""
        logging.info(f"Executing command for {file_path}: {command}")

        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True)
            if result.stdout:
                logging.debug(f"Command output: {result.stdout.strip()}")
            if result.stderr:
                logging.warning(f"Command error: {result.stderr.strip()}")
        except Exception as e:
            logging.error(f"Failed to execute command for {file_path}: {e}")

# Start monitoring the folder
if __name__ == "__main__":
    path = tmp_folder  # The folder to watch (tmp folder from environment)
    event_handler = TmpFolderHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=False)

    logging.info(f"Watching '{path}' for specific files... Press Ctrl+C to stop.")
    observer.start()

    try:
        while True:
            time.sleep(1)  # Keep the script running
    except KeyboardInterrupt:
        logging.info("\nStopping watcher.")
        observer.stop()

    observer.join()
