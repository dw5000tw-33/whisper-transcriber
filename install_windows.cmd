@echo off
setlocal
chcp 65001 >nul
title 33 Works Whisper 語音轉文字安裝

if not exist "%~dp0install_windows.ps1" (
    echo 找不到 install_windows.ps1，請確認已完整解壓縮專案。
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_windows.ps1"
if errorlevel 1 (
    echo.
    echo 安裝未完成，請依照上方錯誤訊息處理後再執行一次。
    pause
    exit /b 1
)
exit /b 0
