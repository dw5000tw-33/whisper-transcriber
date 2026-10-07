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
ArchitecturesInstallIn64BitMode=x64
OutputDir=dist
OutputBaseFilename=33Works-Whisper-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\app.py
SetupLogging=yes

[Languages]
Name: "chinesetrad"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: ".git\*,.venv\*,venv\*,build\*,dist\*,__pycache__\*,*.pyc"

[Icons]
Name: "{autoprograms}\33 Works\Whisper 語音轉文字 安裝"; Filename: "{app}\install_windows.cmd"; WorkingDir: "{app}"

[Run]
Filename: "{app}\install_windows.cmd"; Description: "安裝執行環境並建立桌面捷徑"; Flags: postinstall waituntilterminated skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\.venv"
