param (
    [string]$ModulePath = ".\output_modules\8821cu.ko"
)

$adb = "C:\Users\StringLin\AppData\Local\Android\Sdk\platform-tools\adb.exe"

Write-Host "=== SBC3500 USB Wi-Fi (0bda:b82c) Driver Deployment Script ==="

if (-not (Test-Path $ModulePath)) {
    Write-Host "[Error] Module file not found: $ModulePath" -ForegroundColor Red
    Write-Host "Please specify valid .ko path, e.g.: .\deploy_and_test_wifi.ps1 -ModulePath .\8821cu.ko"
    exit 1
}

Write-Host "[1/5] Checking ADB device connection..."
& $adb devices
& $adb root

Write-Host "[2/5] Remounting /vendor_dlkm as read-write..."
& $adb shell "su 0 mount -o remount,rw /vendor_dlkm"
& $adb shell "su 0 mount -o remount,rw /vendor"

Write-Host "[3/5] Pushing kernel module to /vendor_dlkm/lib/modules/ ..."
& $adb push $ModulePath /data/local/tmp/8821cu.ko
& $adb shell "su 0 cp /data/local/tmp/8821cu.ko /vendor_dlkm/lib/modules/8821cu.ko"
& $adb shell "su 0 cp /data/local/tmp/8821cu.ko /vendor_dlkm/lib/modules/8822bu.ko"
& $adb shell "su 0 chmod 644 /vendor_dlkm/lib/modules/8821cu.ko /vendor_dlkm/lib/modules/8822bu.ko"
& $adb shell "su 0 chown root:root /vendor_dlkm/lib/modules/8821cu.ko /vendor_dlkm/lib/modules/8822bu.ko"

Write-Host "[4/5] Testing direct insmod..."
& $adb shell "su 0 insmod /vendor_dlkm/lib/modules/8821cu.ko"
$dmesgTail = & $adb shell "su 0 dmesg | tail -n 25"
Write-Host $dmesgTail

Write-Host "[5/5] Enabling Wi-Fi and checking network interfaces..."
& $adb shell "su 0 svc wifi enable"
Start-Sleep -Seconds 3

$ipLink = & $adb shell "su 0 ip link show"
Write-Host $ipLink

if ($ipLink -match "wlan0") {
    Write-Host "[Success] wlan0 interface is UP and active!" -ForegroundColor Green
    & $adb shell "su 0 cmd wifi status"
} else {
    Write-Host "[Warning] wlan0 not detected yet. Checking logcat..." -ForegroundColor Yellow
    & $adb shell "su 0 logcat -d -s android.hardware.wifi@1.0-service:E | tail -n 15"
}
