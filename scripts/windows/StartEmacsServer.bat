@echo off

REM Redirect output to a log file for debugging
set LOG_FILE=%HOME%\emacs_restart_log.txt
echo [START] %DATE% %TIME% > "%LOG_FILE%"

echo Listing all running processes... >> "%LOG_FILE%"
tasklist >> "%LOG_FILE%"

echo Logging PATH environment variable... >> "%LOG_FILE%"
echo %PATH% >> "%LOG_FILE%"

echo Checking server directory contents... >> "%LOG_FILE%"
dir "%HOME%\.emacs.d\server" >> "%LOG_FILE%" 2>&1

echo Current working directory: %CD% >> "%LOG_FILE%"

net session >nul 2>&1
if %errorLevel% == 0 (
    echo Script is running as Administrator. >> "%LOG_FILE%"
) else (
    echo WARNING: Script is NOT running as Administrator! >> "%LOG_FILE%"
)

REM Function to check if Emacs is running
call :check_emacs_running

REM Function to delete Emacs server files if they exist
call :delete_emacs_server_files

REM Function to start the Emacs daemon
call :start_emacs_daemon

REM Function to check if the Emacs server is ready
call :check_server_ready

REM Check if optional argument is passed
if "%~1"=="run-client" (
    REM Run emacsclient when the server is ready
    call :run_emacsclient
)

REM Check if optional argument is passed
if "%~1"=="run-client-defered" (
    REM Run emacsclient when the server is ready
    call :run_emacsclient_defered
)

REM Exit the script
exit

:check_emacs_running
REM Check if Emacs is running
REM tasklist /fi "imagename eq emacs.exe" 2>nul | find /i "emacs.exe" >nul
taskkill /f /im emacs.exe >nul 2>&1
if not errorlevel 1 (
    echo Killing Emacs process...
    echo Killing Emacs process... >> "%LOG_FILE%"
    taskkill /f /im emacs.exe >nul 2>&1
    echo Emacs process killed.
    echo Emacs process killed. >> "%LOG_FILE%"
) else (
    echo No Emacs process found to kill.
    echo No Emacs process found to kill. >> "%LOG_FILE%"
)
exit /b

:delete_emacs_server_files
REM Delete Emacs server files
echo Deleting Emacs server files...
echo Deleting Emacs server files... >> "%LOG_FILE%"
if exist "%HOME%\.emacs.d\server\*" (
    del /q "%HOME%\.emacs.d\server\*" >nul 2>&1
    echo Emacs server files deleted.
    echo Emacs server files deleted. >> "%LOG_FILE%"
) else (
    echo No Emacs server files found to delete.
    echo No Emacs server files found to delete. >> "%LOG_FILE%"
)
exit /b

:start_emacs_daemon
REM Start Emacs daemon
echo Starting Emacs daemon...
echo Starting Emacs daemon... >> "%LOG_FILE%"
runemacs --daemon --chdir "%HOME%" >nul 2>&1
echo Emacs daemon started.
echo Emacs daemon started. >> "%LOG_FILE%"
exit /b

:check_server_ready
REM Check if the Emacs server folder has files (to determine if the server is loaded)
echo Checking if Emacs server is ready...
echo Checking if Emacs server is ready... >> "%LOG_FILE%"

:check_server_ready_loop

set SERVER_READY=0
for /f %%f in ('dir "%HOME%\.emacs.d\server" /b 2^>nul') do set SERVER_READY=1

REM If SERVER_READY is set, it means files were found in the server directory
if %SERVER_READY%==1 (
    echo Emacs server is ready.
    echo Emacs server is ready. >> "%LOG_FILE%"
    goto end_check
)

REM Retry the check without any delay
goto check_server_ready_loop

:end_check
exit /b

:run_emacsclient
REM Run emacsclientw when the server is ready
echo Running emacsclient...
echo Running emacsclient... >> "%LOG_FILE%"
start "" "emacsclientw" -c -n
exit /b

:run_emacsclient_defered
REM Run emacsclientw when the Emacs server is ready

echo Running emacsclient defered...
echo Running emacsclient defered... >> "%LOG_FILE%"

REM Define the path for the temporary file that will trigger creating a new frame
set NEW_FRAME_FILE=%HOME%\.emacs.d\create-new-frame

REM Create the trigger file to indicate that Emacs should open a new frame
REM This file acts as a signal to Emacs that it needs to create a new frame
echo start > "%NEW_FRAME_FILE%"

REM If needed, you could uncomment the next line to start emacsclient manually.
REM start "" "emacsclientw" -c -n

exit /b
