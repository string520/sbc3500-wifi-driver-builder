@echo off
chcp 65001 >nul
cd /d "C:\Users\StringLin\Desktop\SBC3500_WiFi_Driver_CrossCompile"

echo ========================================================
echo  正在推送專案至 GitHub (string520/sbc3500-wifi-driver-builder)
echo ========================================================
echo.

git remote remove origin >nul 2>&1
git remote add origin https://github.com/string520/sbc3500-wifi-driver-builder.git
git branch -M main

echo 請在彈出的 GitHub 視窗中點選「Sign in with your browser」完成授權...
git push -u origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================================
    echo  [成功] 專案已成功推送至 GitHub！
    echo  GitHub Actions 雲端自動編譯已啟動。
    echo  請等待約 3 ~ 4 分鐘後至 GitHub 專案的 Actions 下載產物。
    echo ========================================================
) else (
    echo.
    echo [失敗] 推送未完成，請確認網路或 GitHub 權限。
)

echo.
pause
