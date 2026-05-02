# Whisper 語音轉文字

一個使用 OpenAI Whisper 的桌面語音轉文字工具
支援本機音檔與 YouTube 網址轉錄，並可輸出 `.txt` 文字檔

----

## ✨ 功能

* 🎧 支援音檔轉文字（mp3 / mp4 / wav 等）
* 🌐 支援 YouTube 網址轉錄
* ⚡ 即時顯示轉錄結果
* 📄 可輸出文字檔
* 🎛 可選模型與語言

---

## 🧰 環境需求

建議使用：

* Python 3.10 或 3.11
* ffmpeg
* Node.js（僅 YouTube 需要）

---

## 📦 安裝 Python 套件

```bash
pip install -r requirements.txt
```

---

## ⚠️ 安裝 ffmpeg（必要）

本工具需要 ffmpeg 才能運作

👉 安裝後請確認：

```bash
ffmpeg -version
```

若出現版本資訊代表成功

---

## ⚠️ 安裝 Node.js（YouTube 需要）

如果要使用 YouTube 轉錄功能

👉 請確認：

```bash
node -v
```

若出現版本資訊代表成功

---

## 🚀 執行

```bash
python app.py
```

---

## 📌 使用說明

1. 選擇音檔 或 貼上 YouTube 網址
2. 選擇輸出文字檔位置
3. 點擊「開始轉錄」
4. 等待完成即可

---

## ❗ 注意事項

* 第一次使用會下載 Whisper 模型（需等待）
* 模型越大 → 越準，但越慢
* 若出現「找不到 ffmpeg」→ 請確認已加入 PATH
* 若 YouTube 失敗 → 請確認 Node.js

---

## 👨‍💻 作者

GitHub: https://github.com/dw5000tw-33
