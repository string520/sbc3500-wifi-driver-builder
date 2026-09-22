param (
    [Parameter(Mandatory = $true)]
    [string]$RepoUrl
)

$ErrorActionPreference = "Stop"
$workDir = "C:\Users\StringLin\Desktop\SBC3500_WiFi_Driver_CrossCompile"
Set-Location $workDir

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "[1/3] 設定遠端倉庫並推送至 GitHub..." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 檢查 remote
$existingRemote = git remote -v
if ($existingRemote -match "origin") {
    git remote set-url origin $RepoUrl
} else {
    git remote add origin $RepoUrl
}

Write-Host "正在推送 main 分支至 $RepoUrl ..." -ForegroundColor Yellow
git branch -M main
git push -u origin main

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "[2/3] 推送完成！GitHub Actions 已自動啟動雲端編譯。" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "系統正於雲端 Ubuntu 22.04 環境中自動編譯（耗時約 3 ~ 4 分鐘）：" -ForegroundColor Yellow
Write-Host "  * 8821cu.ko (支援 0bda:b82c)"
Write-Host "  * 8822bu.ko (支援 0bda:b82c)"

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "[3/3] 下載產物並一鍵寫入機台" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "編譯完成後："
Write-Host "  1. 前往專案頁面 -> Actions -> 點選最新 Workflow"
Write-Host "  2. 於最下方 Artifacts 下載 sbc3500-wifi-modules-5.10.157.zip"
Write-Host "  3. 解壓縮後將 .ko 放入 output_modules 資料夾"
Write-Host "  4. 執行一鍵部署指令："
Write-Host "     .\deploy_and_test_wifi.ps1 -ModulePath .\output_modules\8821cu.ko" -ForegroundColor Green
