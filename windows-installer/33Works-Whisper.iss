; 33 Works Whisper Transcriber Windows installer
#define MyAppName "33 Works Whisper 語音轉文字"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "33 Works"
#define MyAppExeName "install_windows.cmd"

[Setup]
AppId={{8E4E8864-8E0D-4A99-93F4-8CB3D5CE7B75}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\Programs\33Works\WhisperTranscriber
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
SourceDir=..
OutputDir=windows-installer\dist
OutputBaseFilename=33Works-Whisper-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName={#MyAppName}
SetupLogging=yes

[Languages]
Name: "chinesetrad"; MessagesFile: "compiler:Languages\ChineseTraditional.isl"

[Files]
Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: ".git\*,.github\*,.venv\*,venv\*,build\*,dist\*,windows-installer\*,__pycache__\*,*.pyc"


[Run]
Filename: "{app}\install_windows.cmd"; Description: "安裝執行環境並建立桌面捷徑"; Flags: waituntilterminated

[UninstallDelete]
Type: filesandordirs; Name: "{app}\.venv"
