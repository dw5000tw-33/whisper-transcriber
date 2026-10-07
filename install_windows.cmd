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
  for %%V in (3.14 3.13 3.12 3.11 3.10) do (
    if not defined PY_CMD (
      py -%%V -c "import sys" >nul 2>nul
      if not errorlevel 1 set "PY_CMD=py -%%V"
    )
  )
)
if not defined PY_CMD (
  python -c "import sys; raise SystemExit(0 if (3,10) <= sys.version_info[:2] <= (3,14) else 1)" >nul 2>nul
  if not errorlevel 1 set "PY_CMD=python"
)

if not defined PY_CMD (
  where winget >nul 2>nul
  if errorlevel 1 (
    echo No supported Python was found. Opening the official Python download page.
    start "" "https://www.python.org/downloads/windows/"
    echo Install Python 3.10 to 3.14, then run install_windows.cmd again.
    pause
    exit /b 1
  )
  echo No supported Python was found.
  choice /C YN /N /M "Install Python 3.11 with Windows Package Manager now? [Y/N] "
  if errorlevel 2 (
    echo Opening the official Python download page.
    start "" "https://www.python.org/downloads/windows/"
    echo Install Python 3.10 to 3.14, then run install_windows.cmd again.
    pause
    exit /b 1
  )
  winget install --id Python.Python.3.11 --exact
  if errorlevel 1 (
    echo Python installation did not finish. You can install Python manually.
    start "" "https://www.python.org/downloads/windows/"
    pause
    exit /b 1
  )
  echo Python installation finished. Close this window and run install_windows.cmd again.
  pause
  exit /b 0
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
