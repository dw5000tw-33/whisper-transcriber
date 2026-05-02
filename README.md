# 🎙 Whisper 語音轉文字

一個使用 OpenAI Whisper 的桌面語音轉文字工具  
支援本機音檔與 YouTube 網址轉錄，並可輸出 `.txt` 文字檔


📌 30 秒快速了解操作方式
![操作流程](./whisper_usage_flow.gif)

---

## ✨ 功能

- 🎧 支援音檔轉文字（mp3 / mp4 / wav 等）
- 🌐 支援 YouTube 網址轉錄
- ⚡ 即時顯示轉錄結果
- 📄 可輸出文字檔
- 🎛 可選模型與語言

---

## 🧰 環境需求

建議使用：

- Python 3.10 或 3.11
- ffmpeg
- Node.js（僅 YouTube 需要）

---

## 🚀 快速使用

### 1️⃣ 下載專案

在 GitHub 頁面點選：

```
Code → Download ZIP
```

解壓縮後進入專案資料夾。

---

### 2️⃣ 安裝 Python 套件（PowerShell / CMD）

```bash
pip install -r requirements.txt
```

---

### 3️⃣ 確認 ffmpeg

```bash
ffmpeg -version
```

若出現版本資訊代表成功  
尚未安裝請參考下方說明

---

### 4️⃣ 確認 Node.js（YouTube 需要）

```bash
node -v
```

若出現版本資訊代表成功  
尚未安裝請參考下方說明

---

### 5️⃣ 執行工具（PowerShell / CMD）

```bash
python app.py
```

---

## 📌 使用流程

1. 選擇音檔，或貼上 YouTube 網址  
2. 選擇輸出文字檔位置  
3. 點擊「開始轉錄」  
4. 等待完成  

---

## ⚙️ ffmpeg 安裝與環境變數設定（Windows）

### 1️⃣ 下載 ffmpeg

https://www.gyan.dev/ffmpeg/builds/

下載：

```
ffmpeg-release-full.zip
```

---

### 2️⃣ 解壓縮

建議解壓到：

```
C:\ffmpeg
```

完成後應該看到類似：

```
C:\ffmpeg\ffmpeg-xxxx\bin\ffmpeg.exe
```

👉 這個 `bin` 路徑稍後會用到（設定 PATH）

---

### 3️⃣ 加入 PATH

1. Windows 搜尋：環境變數  
2. 點選：編輯系統環境變數  
3. 點選：環境變數  
4. 在「系統變數」找到 Path  
5. 點選：編輯  
6. 點選：新增  
7. 貼上：

```
C:\ffmpeg\ffmpeg-xxxx\bin
```

8. 不斷按「確定」

---

### 4️⃣ 重新開啟終端機

關閉 PowerShell / CMD，重新開啟新的終端機

---

### 5️⃣ 測試 ffmpeg

```bash
ffmpeg -version
```

若顯示版本資訊代表成功

---

## ⚙️ Node.js 安裝說明（YouTube 轉錄功能）

👉 若只使用本機音檔，可以跳過此步驟 
如果要使用 YouTube 網址轉錄，建議安裝 Node.js

---

### 1️⃣ 下載 Node.js

https://nodejs.org/

下載並安裝 LTS 版本

---

### 2️⃣ 測試 Node.js

```bash
node -v
```

若顯示版本號，代表成功

---

## ❗❗ 常見問題（🛠 自我排除方法）

### ⚠️ 找不到 ffmpeg

通常是以下原因：

- 沒有加入 PATH
- PATH 加錯層（必須加到 `bin`）
- 沒有重新開啟 PowerShell / CMD

---

### ⚠️ 點兩下 ffmpeg.exe 閃退

這是正常現象  

ffmpeg 是命令列工具，不是一般安裝程式

---

### ⚠️ 找不到 node

請確認：

- Node.js 已安裝
- 已重新開啟終端機
- Node.js 已加入 PATH

---

### ⚠️ 第一次使用很慢

第一次使用 Whisper 會下載模型  
請保持網路連線並等待完成

---

### ⚠️ YouTube 轉錄失敗

```bash
node -v
```

若沒有顯示版本資訊，請先安裝 Node.js  
如果只使用本機音檔，可以忽略 Node.js

---

## 👨‍💻 作者

⭐ 如果這個工具對你有幫助，歡迎給個 Star

GitHub: https://github.com/dw5000tw-33

## ❤️ 支持開發者

如果這個工具對你有幫助，歡迎之後支持開發者 🙏  
（斗內功能審核中，之後會開放）
