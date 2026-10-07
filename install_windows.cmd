@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

if not exist "app.py" (
  echo ERROR: app.py was not found in this folder.
  pause
  exit /b 1
)
if not exist "requirements.txt" (
  echo ERROR: requirements.txt was not found in this folder.
  pause
  exit /b 1
)

set "PY_CMD="
where py >nul 2>nul
if not errorlevel 1 (
  py -3.11 -c "import sys" >nul 2>nul
  if not errorlevel 1 set "PY_CMD=py -3.11"
  if not defined PY_CMD (
    py -3.10 -c "import sys" >nul 2>nul
    if not errorlevel 1 set "PY_CMD=py -3.10"
  )
)
if not defined PY_CMD (
  python -c "import sys; raise SystemExit(0 if sys.version_info[:2] in ((3,10),(3,11)) else 1)" >nul 2>nul
  if not errorlevel 1 set "PY_CMD=python"
)

if not defined PY_CMD (
  echo ERROR: Python 3.10 or 3.11 was not found.
  echo Install Python 3.10 or 3.11, select Add Python to PATH, then run this file again.
  pause
  exit /b 1
)

echo Creating the project virtual environment...
if not exist ".venv\Scripts\python.exe" (
  %PY_CMD% -m venv .venv
  if errorlevel 1 (
    echo ERROR: Could not create .venv.
    pause
    exit /b 1
  )
)

echo Installing Python packages. This may take several minutes.
".venv\Scripts\python.exe" -m pip install --upgrade pip
if errorlevel 1 (
  echo ERROR: pip could not be upgraded. Check your Internet connection and try again.
  pause
  exit /b 1
)
".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 (
  echo ERROR: Package installation failed. Check your Internet connection and try again.
  pause
  exit /b 1
)

if not exist "ffmpeg.exe" (
  where ffmpeg >nul 2>nul
  if errorlevel 1 echo NOTICE: FFmpeg was not found. Install FFmpeg before transcribing audio.
)
where node >nul 2>nul
if errorlevel 1 echo NOTICE: Node.js was not found. It is needed only for YouTube URLs.

echo Creating a desktop shortcut...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0create_shortcut.ps1" -ProjectPath "%~dp0"
if errorlevel 1 (
  echo NOTICE: The shortcut could not be created. You can still run START_WHISPER.cmd.
)

echo Setup finished.
echo Run START_WHISPER.cmd to open the Whisper panel.
pause
