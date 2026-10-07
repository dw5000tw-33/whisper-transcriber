param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$project = (Resolve-Path -LiteralPath $ProjectPath).Path
$target = Join-Path $project "START_WHISPER.cmd"

if (-not (Test-Path -LiteralPath $target)) {
    throw "START_WHISPER.cmd was not found."
}

$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = [Environment]::GetFolderPath("Programs")
$shortcuts = @(
    (Join-Path $desktop "Whisper Transcriber.lnk"),
    (Join-Path $startMenu "Whisper Transcriber.lnk")
)

$shell = New-Object -ComObject WScript.Shell
foreach ($shortcutPath in $shortcuts) {
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $target
    $shortcut.WorkingDirectory = $project
    $shortcut.Description = "Open the Whisper Transcriber panel"
    $shortcut.Save()
}
