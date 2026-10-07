@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
  echo ERROR: The environment is not installed. Run install_windows.cmd first.
  pause
  exit /b 1
)
if not exist "app.py" (
  echo ERROR: app.py was not found in this folder.
  pause
  exit /b 1
)

".venv\Scripts\python.exe" app.py
if errorlevel 1 (
  echo.
  echo The program stopped with an error. Read the message above.
  pause
)
