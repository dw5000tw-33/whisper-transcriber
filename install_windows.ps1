# 33 Works Whisper Transcriber - Windows setup
$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Invoke-WingetInstall([string]$Id) {
    $listed = & winget list --id $Id --exact --accept-source-agreements 2>&1 | Out-String
    if ($listed -match [regex]::Escape($Id)) {
        Write-Host "$Id is already installed."
        return
    }
    Write-Step "Installing $Id"
    & winget install --id $Id --exact --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "winget could not install $Id (exit code $LASTEXITCODE)." }
}

function Refresh-ProcessPath {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = @($machinePath, $userPath, "$env:LOCALAPPDATA\Microsoft\WinGet\Links") -join ";"
}

function Find-Python311 {
    $launcher = Get-Command py.exe -ErrorAction SilentlyContinue
    if ($launcher) {
        & $launcher.Source -3.11 -c "import sys; print(sys.executable)" 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) { return @{ Launcher = $launcher.Source; Args = @("-3.11") } }
    }
    $roots = @("HKCU:\Software\Python\PythonCore", "HKLM:\Software\Python\PythonCore", "HKLM:\Software\WOW6432Node\Python\PythonCore")
    foreach ($root in $roots) {
        if (Test-Path $root) {
            foreach ($version in Get-ChildItem $root -ErrorAction SilentlyContinue) {
                if ($version.PSChildName -like "3.11*") {
                    $install = Get-ItemProperty ($version.PSPath + "\InstallPath") -ErrorAction SilentlyContinue
                    if ($install) {
                        $candidate = Join-Path $install.'(default)' "python.exe"
                        if (Test-Path $candidate) { return @{ Launcher = $candidate; Args = @() } }
                    }
                }
            }
        }
    }
    return $null
}

function Invoke-Checked([string]$Executable, [string[]]$Arguments) {
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Command failed: $Executable (exit code $LASTEXITCODE)" }
}

try {
    if (-not $env:PROCESSOR_ARCHITECTURE -or $env:PROCESSOR_ARCHITECTURE -notmatch "64") {
        throw "This installer currently supports 64-bit Windows only."
    }
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw "winget was not found. Install or update App Installer from Microsoft Store, then run this installer again."
    }

    Write-Step "Checking required Windows components"
    Invoke-WingetInstall "Python.Python.3.11"
    Invoke-WingetInstall "Gyan.FFmpeg"
    Invoke-WingetInstall "OpenJS.NodeJS.LTS"
    Refresh-ProcessPath

    $python = Find-Python311
    if (-not $python) {
        throw "Python 3.11 was installed, but Windows could not find it yet. Sign out and back in, then run install_windows.cmd again."
    }

    $sourceDir = (Resolve-Path $PSScriptRoot).Path
    $appDir = Join-Path $env:LOCALAPPDATA "Programs\33Works\WhisperTranscriber"
    New-Item -ItemType Directory -Path $appDir -Force | Out-Null

    if ($sourceDir.TrimEnd('\') -ne $appDir.TrimEnd('\')) {
        Write-Step "Copying the application"
        & robocopy $sourceDir $appDir /E /XD ".git" ".venv" "venv" "build" "dist" "__pycache__" /XF "install_windows.cmd" "install_windows.ps1"
        if ($LASTEXITCODE -ge 8) { throw "Could not copy application files (robocopy exit code $LASTEXITCODE)." }
    }

    if (-not (Get-Command ffmpeg.exe -ErrorAction SilentlyContinue)) { throw "FFmpeg installation completed, but ffmpeg.exe is not on PATH. Restart Windows and try again." }
    if (-not (Get-Command node.exe -ErrorAction SilentlyContinue)) { throw "Node.js installation completed, but node.exe is not on PATH. Restart Windows and try again." }

    $venvPython = Join-Path $appDir ".venv\Scripts\python.exe"
    if (-not (Test-Path $venvPython)) {
        Write-Step "Creating the private Python environment"
        Invoke-Checked $python.Launcher ($python.Args + @("-m", "venv", (Join-Path $appDir ".venv")))
    }

    Write-Step "Installing transcription packages (this may take several minutes)"
    Invoke-Checked $venvPython @("-m", "pip", "install", "--upgrade", "pip")
    Invoke-Checked $venvPython @("-m", "pip", "install", "-r", (Join-Path $appDir "requirements.txt"))

    Write-Step "Creating a desktop shortcut"
    $shell = New-Object -ComObject WScript.Shell
    $shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "33 Works Whisper 語音轉文字.lnk"
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = Join-Path $appDir ".venv\Scripts\pythonw.exe"
    $shortcut.Arguments = '"' + (Join-Path $appDir "app.py") + '"'
    $shortcut.WorkingDirectory = $appDir
    $shortcut.Description = "33 Works Whisper 語音轉文字"
    $shortcut.Save()

    Write-Step "Installation complete"
    Write-Host "The desktop shortcut is ready. The first transcription downloads the selected Whisper model."
    $choice = Read-Host "Open the app now? [Y/n]"
    if ($choice -notmatch "^(n|no)$") {
        Start-Process -FilePath $shortcut.TargetPath -ArgumentList $shortcut.Arguments -WorkingDirectory $appDir
    }
}
catch {
    Write-Host ""
    Write-Host "Installation did not finish:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to close"
    exit 1
}
