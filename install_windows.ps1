param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"

function Refresh-Path {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

function Get-PythonExecutable {
    Refresh-Path
    $launcher = Get-Command py.exe -ErrorAction SilentlyContinue
    if ($launcher) {
        foreach ($version in @("3.14", "3.13", "3.12", "3.11", "3.10")) {
            $output = & $launcher.Source "-$version" -c "import sys; print(sys.executable)" 2>$null
            if ($LASTEXITCODE -eq 0 -and $output) {
                return ($output | Select-Object -Last 1).Trim()
            }
        }
    }

    $python = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($python -and $python.Source -notmatch "\\WindowsApps\\") {
        $output = & $python.Source -c "import sys; print(sys.executable) if (3,10) <= sys.version_info[:2] <= (3,14) else sys.exit(1)" 2>$null
        if ($LASTEXITCODE -eq 0 -and $output) {
            return ($output | Select-Object -Last 1).Trim()
        }
    }

    foreach ($candidate in @(
        (Join-Path $env:LOCALAPPDATA "Programs\Python\Python311\python.exe"),
        (Join-Path $env:ProgramFiles "Python311\python.exe")
    )) {
        if (Test-Path -LiteralPath $candidate) {
            $output = & $candidate -c "import sys; print(sys.executable) if (3,10) <= sys.version_info[:2] <= (3,14) else sys.exit(1)" 2>$null
            if ($LASTEXITCODE -eq 0) {
                return $candidate
            }
        }
    }
    return $null
}

function Install-WingetPackage([string]$PackageId) {
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $winget) {
        return $false
    }
    Write-Host "Installing $PackageId. Follow any Windows or package agreement prompts."
    & $winget.Source install --id $PackageId --exact --source winget
    if ($LASTEXITCODE -ne 0) {
        throw "WinGet could not install $PackageId. Read the message above and try again."
    }
    Refresh-Path
    return $true
}

try {
    $ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path
    Set-Location -LiteralPath $ProjectPath

    if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath "app.py"))) {
        throw "app.py was not found. Extract the full project ZIP and run the installer inside its folder."
    }
    if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath "requirements.txt"))) {
        throw "requirements.txt was not found."
    }

    $pythonExe = Get-PythonExecutable
    if (-not $pythonExe) {
        Write-Host "Supported Python was not found. Python 3.11 will be installed."
        if (-not (Install-WingetPackage "Python.Python.3.11")) {
            Start-Process "https://www.python.org/downloads/windows/"
            throw "WinGet is not available. Install Python 3.10 to 3.14 from the page opened, then run this installer again."
        }
        $pythonExe = Get-PythonExecutable
        if (-not $pythonExe) {
            throw "Python installation finished, but Windows has not registered it yet. Close this window, open a new one, and run install_windows.cmd again."
        }
    }
    Write-Host "Using Python: $pythonExe"

    Refresh-Path
    if (-not (Get-Command ffmpeg.exe -ErrorAction SilentlyContinue)) {
        Write-Host "FFmpeg was not found. Installing it now."
        if (-not (Install-WingetPackage "Gyan.FFmpeg.Shared")) {
            Start-Process "https://ffmpeg.org/download.html"
            throw "WinGet is not available. Install an FFmpeg Windows build, add its bin folder to PATH, then run this installer again."
        }
        if (-not (Get-Command ffmpeg.exe -ErrorAction SilentlyContinue)) {
            $wingetLinks = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links"
            if (Test-Path -LiteralPath (Join-Path $wingetLinks "ffmpeg.exe")) {
                $env:Path = "$wingetLinks;$env:Path"
            }
        }
        if (-not (Get-Command ffmpeg.exe -ErrorAction SilentlyContinue)) {
            throw "FFmpeg installation finished, but ffmpeg.exe is not available in PATH. Restart Windows, then run this installer again."
        }
    }

    $node = Get-Command node.exe -ErrorAction SilentlyContinue
    if (-not $node) {
        $answer = Read-Host "Install Node.js LTS for YouTube URL support? Enter Y to install, or press Enter to skip"
        if ($answer -match "^(Y|YES)$") {
            try {
                if (Install-WingetPackage "OpenJS.NodeJS.LTS") {
                    if (-not (Get-Command node.exe -ErrorAction SilentlyContinue)) {
                        Write-Host "Node.js was installed. Open a new terminal later if YouTube support is not detected."
                    }
                } else {
                    Start-Process "https://nodejs.org/"
                    Write-Host "WinGet is not available. Install Node.js LTS from the page opened. You can skip this for local audio files."
                }
            } catch {
                Write-Host "Node.js setup was skipped. You can install it later for YouTube URL support."
            }
        }
    }

    $venvPython = Join-Path $ProjectPath ".venv\Scripts\python.exe"
    if (-not (Test-Path -LiteralPath $venvPython)) {
        Write-Host "Creating the project virtual environment..."
        & $pythonExe -m venv (Join-Path $ProjectPath ".venv")
        if ($LASTEXITCODE -ne 0) {
            throw "Could not create the virtual environment."
        }
    }

    Write-Host "Installing Python packages. This can take several minutes."
    & $venvPython -m pip install --upgrade pip
    if ($LASTEXITCODE -ne 0) {
        throw "Could not update pip. Check the Internet connection and try again."
    }
    & $venvPython -m pip install -r (Join-Path $ProjectPath "requirements.txt")
    if ($LASTEXITCODE -ne 0) {
        throw "Python package installation failed. Check the Internet connection and try again."
    }

    & (Join-Path $ProjectPath "create_shortcut.ps1") -ProjectPath $ProjectPath
    if ($LASTEXITCODE -ne 0) {
        throw "Could not create the desktop shortcut."
    }

    Write-Host "Setup is complete. Opening the Whisper panel."
    Start-Process -FilePath (Join-Path $ProjectPath "START_WHISPER.cmd") -WorkingDirectory $ProjectPath
    exit 0
} catch {
    Write-Host ("ERROR: " + $_.Exception.Message)
    exit 1
}
