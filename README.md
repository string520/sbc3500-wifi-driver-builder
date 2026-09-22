# SBC3500 (Android 13 / Linux 5.10.157) USB Wi-Fi 驅動交叉編譯與部署指南

## 一、 專案目標與硬體規格
* **目標硬體**：Realtek RTL8821CU / RTL8822BU USB 雙頻 Wi-Fi + 藍牙網卡
* **硬體識別碼**：VID:PID = `0bda:b82c`（介面 `5-1.2.4:1.2`，Class `0xff`）
* **機台環境**：SBC3500 工控主機板（Rockchip 平台）
* **作業系統**：Android 13（Kernel: `Linux 5.10.157 aarch64`）
* **編譯約束**：
  * Vermagic: `5.10.157 SMP preempt mod_unload modversions aarch64`
  * 工具鏈: Android Clang 14.0.6 (r450784d) / GCC aarch64-linux-gnu

---

## 二、 編譯途徑說明

### 途徑 A：透過 GitHub Actions 雲端自動化編譯（推薦）
本目錄已配置完整之 CI/CD 流程檔：[build_wifi_modules.yml](file:///.github/workflows/build_wifi_modules.yml)。

#### 操作步驟：
1. **建立 GitHub 儲存庫**：
   在個人或組織 GitHub 建立一個新的 Repository（例如 `sbc3500-wifi-driver-builder`）。
2. **推送本目錄檔案**：
   將本 `kernel_cross_compile` 資料夾內之所有檔案（包含 `.github/workflows/build_wifi_modules.yml` 與 `sbc3500_android13.config`）推送到該 GitHub 儲存庫：
   ```bash
   git init
   git add .
   git commit -m "feat: add rockchip 5.10.157 wifi driver build workflow"
   git branch -M main
   git remote add origin <您的 GitHub 儲存庫網址>
   git push -u origin main
   ```
3. **自動執行編譯**：
   * 推送完成後，GitHub Actions 將自動啟動（或至 GitHub 網頁端點選「Actions」分頁 -> 選擇工作流「Build Rockchip RTL8821CU and RTL8822BU Modules」-> 點擊「Run workflow」）。
   * 系統將自動拉取 Rockchip 5.10 核心源碼、注入 SBC3500 實機設定檔、編譯出匹配之驅動模組，建置時間約 3 至 5 分鐘。
4. **下載編譯成品**：
   編譯完成後，在該次 Workflow 執行結果頁面的 **Artifacts** 區塊，直接下載 `sbc3500-wifi-modules-5.10.157.zip`。
   解壓縮後即可取得：
   * `8821cu.ko`
   * `8822bu.ko`

---

### 途徑 B：本地 Linux / Docker 環境手動編譯
若有現成的 Ubuntu 20.04/22.04 實體機、虛擬機或 Docker 環境，可直接執行腳本：
```bash
chmod +x build_local.sh
./build_local.sh
```
編譯完成後，模組檔案將存放於 `output_modules/` 資料夾內。

---

## 三、 模組部署與實機驗證步驟

下載產出之 `.ko` 檔案後，回到 Windows 環境執行自動化部署：

### 1. 執行自動部署腳本
開啟 PowerShell，切換至本目錄執行：
```powershell
.\deploy_and_test_wifi.ps1 -ModulePath .\output_modules\8821cu.ko
```

### 2. 腳本自動執行之核心動作
1. 取得機台 ADB Root 與重新掛載讀寫權限：
   ```bash
   mount -o remount,rw /vendor_dlkm
   mount -o remount,rw /vendor
   ```
2. 推送驅動模組至系統核心目錄：
   ```bash
   cp /data/local/tmp/8821cu.ko /vendor_dlkm/lib/modules/8821cu.ko
   cp /data/local/tmp/8821cu.ko /vendor_dlkm/lib/modules/8822bu.ko
   chmod 644 /vendor_dlkm/lib/modules/8821cu.ko /vendor_dlkm/lib/modules/8822bu.ko
   ```
3. 執行模組載入與 Wi-Fi HAL 啟動：
   ```bash
   insmod /vendor_dlkm/lib/modules/8821cu.ko
   svc wifi enable
   ```
4. 驗證介面狀態：
   透過 `ip link show` 檢查 `wlan0` 是否正常產生並進入 UP 狀態。

---

## 四、 故障排除與日誌追蹤
* **檢視內核掛載日誌**：
  ```powershell
  adb shell "su 0 dmesg | grep -E '8821cu|8822bu|wlan'"
  ```
* **檢視 Wi-Fi HAL 啟動日誌**：
  ```powershell
  adb shell "su 0 logcat -d -s android.hardware.wifi@1.0-service:E"
  ```
