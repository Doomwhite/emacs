# Define the path to your .env file and the directory to monitor
$envFile = "C:\Users\Cliente\.emacs.d\.env"
$monitorDir = "C:\Users\Cliente\.emacs.d"  # Directory to watch

# Load environment variable from the .env file
$envContent = Get-Content $envFile | Where-Object { $_ -notmatch '^\s*#' }  # Ignore comments
$envVar = ($envContent -match "^CREATE_NEW_FRAME_FILE_NAME=(.*)$") | Out-Null
$triggerFile = $matches[1]

# Check if the file name exists (for sanity check)
if (-not $triggerFile) {
    Write-Host "Error: 'CREATE_NEW_FRAME_FILE_NAME' is not set correctly in .env"
    exit
}

Write-Host "Watching for file creation: $triggerFile"

# Run watchexec to monitor the directory
Start-Process "watchexec" -ArgumentList "--watch", $monitorDir, "--filter", $triggerFile, "--", $command
