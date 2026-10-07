@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

set "PROJECT_PATH=%~dp0."
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_windows.ps1" -ProjectPath "%PROJECT_PATH%"
if errorlevel 1 (
  echo.
  echo Setup did not finish. Read the error above.
)
pause
