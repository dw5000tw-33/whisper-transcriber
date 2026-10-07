# 🎙 Whisper 語音轉文字

33 Works 的桌面語音轉文字工具，使用 OpenAI Whisper，在使用者自己的 Windows 電腦處理音檔。

支援本機音檔與 YouTube 網址轉錄，並可輸出 `.txt` 文字檔。

## 功能

- 支援音訊／影片檔（mp3、m4a、wav、mp4 等）
- 支援 YouTube 網址轉錄
- 即時顯示轉錄結果
- 可選擇 Whisper 模型與語言
- 可選擇文字檔輸出位置

## Windows 安裝（建議）

### 一鍵圖形安裝

1. 在 GitHub 專案頁下載 ZIP，按右鍵選「全部解壓縮」。
2. 開啟解壓後的資料夾，執行 `install_windows.cmd`。
3. 安裝程式會檢查並準備 Python 3.11、FFmpeg 和 Node.js LTS，再安裝程式套件。
4. 完成後，從桌面或開始選單開啟「33 Works Whisper 語音轉文字」。

安裝需要網路連線和 Windows Package Manager（winget）。如果電腦找不到 winget，請先從 Microsoft Store 安裝或更新「App Installer」，再重新執行安裝檔。安裝套件會透過 winget 安裝到 Windows；Whisper 模型則在第一次轉錄時下載。

### CMD 安裝

在已解壓縮的專案資料夾開啟 CMD，執行：

```bat
install_windows.cmd
```

也可以在 CMD 先切換到專案資料夾，再執行相同指令。這和雙擊安裝入口使用同一套檢查及安裝流程。

### 圖形安裝檔（Setup.exe）

專案提供 Inno Setup 安裝檔定義，GitHub Actions 可在 Windows 環境產生 `33Works-Whisper-Setup.exe`。推送 `v` 開頭的版本標籤，或手動執行「Build Windows installer」工作流程後，可從該次工作流程的 Artifact 下載安裝檔。

目前產生的安裝檔尚未使用程式碼簽章。Windows 可能顯示發行者或 SmartScreen 警告；簽章需要另外申請與設定，不能假設安裝警告一定會消失。

## 手動安裝（替代方式）

需要自行處理環境時，使用 Python 3.11、FFmpeg 和 Node.js LTS：

```bat
py -3.11 -m venv .venv
.venv\Scripts\python.exe -m pip install --upgrade pip
.venv\Scripts\python.exe -m pip install -r requirements.txt
.venv\Scripts\python.exe app.py
```

FFmpeg 是本機音檔轉錄所需；Node.js 是 YouTube 網址轉錄所需。完成安裝後，若要建立桌面捷徑，建議使用 `install_windows.cmd`。

## 使用流程

1. 選擇音檔或貼上 YouTube 網址。
2. 選擇輸出文字檔位置。
3. 選擇模型與語言。
4. 點擊「開始轉錄」並等待完成。

選擇本機音檔後，程式預設將 `.txt` 輸出位置放在音檔所在資料夾；使用者仍可在面板中自行更改。

## 常見狀況

- **安裝時下載時間較長：** Whisper 使用 PyTorch 等套件，第一次安裝會下載執行所需套件。
- **第一次轉錄較慢：** 第一次使用所選 Whisper 模型時會下載模型檔。
- **找不到 winget：** 安裝或更新 Microsoft Store 的 App Installer，再執行安裝檔。
- **YouTube 轉錄失敗：** 確認 Node.js LTS 已安裝，並重新開啟應用程式。
- **轉錄速度較慢：** 模型越大通常越耗用電腦資源；可先改用較小模型。

## 開發者

GitHub：<https://github.com/dw5000tw-33>

如果這個工具對你有幫助，歡迎自由支持後續開發與維護。支持完全自願，不影響工具的免費使用。

[透過綠界支持 33 Works](https://p.ecpay.com.tw/304E8B5)

## 授權

本專案採 MIT License。第三方套件與模型仍依各自授權條款使用。
