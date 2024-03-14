@echo off
REM Kill emacs.exe process
taskkill /f /im emacs.exe

REM Delete Emacs server files
del /q %HOME%\.config\emacs\server\*

REM Start Emacs daemon
runemacs --daemon --chdir %HOME%
