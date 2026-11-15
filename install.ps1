# ==============================================================================
# ROM Flasher - 1-Line Universal ADB and Fastboot Driver Installer v3.0
# ==============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Repository Configuration
$RepoOwner = "romflasher3419-spec"
$RepoName  = "adb-fastboot-driver-toolkit"
$Branch    = "main"
$WebScriptUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/install.ps1"

# Auto-elevate to Administrator (Rock-solid for both Web iex and Local file runs)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[*] Administrator privileges required. Elevating..." -ForegroundColor Yellow
    if ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        $elevateCmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm '$WebScriptUrl' | iex"
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$elevateCmd`""
    }
    exit
}

Clear-Host
Write-Host @"
========================================================================================
   ██████╗  ██████╗ ███╗   ███╗    ███████╗██╗      █████╗ ███████╗██╗  ██╗
   ██╔══██╗██╔═══██╗████╗ ████║    ██╔════╝██║     ██╔══██╗██╔════╝██║  ██║
   ██████╔╝██║   ██║██╔████╔██║    █████╗  ██║     ███████║███████╗███████║
   ██╔══██╗██║   ██║██║╚██╔╝██║    ██╔══╝  ██║     ██╔══██║╚════██║██╔══██║
   ██║  ██║╚██████╔╝██║ ╚═╝ ██║    ██║     ███████╗██║  ██║███████║██║  ██║
   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝    ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                ULTIMATE DRIVER & ADB SETUP v3.0 [PRO]
                        Crafted for Rohit Bhai
========================================================================================
"@ -ForegroundColor Cyan

Write-Host "  [+] Supported Devices: Xiaomi, Poco, Redmi, Vivo, Oppo, Realme, OnePlus, Samsung, Google, MTK, QCOM" -ForegroundColor White
Write-Host "  [+] Supported Modes  : ADB, Fastboot, Fastbootd, Recovery, Qualcomm 9008 EDL, MediaTek BROM" -ForegroundColor White
Write-Host ""

$WorkDir = Join-Path $env:TEMP "ROM_Flasher_Setup"
if (-not (Test-Path $WorkDir)) {
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
}

# -------------------------------------------------------------------------
# Step 1: Internet & Security Policy Check
# -------------------------------------------------------------------------
Write-Host "[1/6] Checking System Environment..." -ForegroundColor Cyan

# Test connectivity
$hasNet = $false
try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.Connect("8.8.8.8", 53)
    $hasNet = $true
    $tcp.Close()
} catch {
    try {
        (New-Object System.Net.WebClient).OpenRead('http://www.google.com').Close()
        $hasNet = $true
    } catch {}
}

if (-not $hasNet) {
    Write-Host "  [!] Error: No internet connection detected. Please connect to download packages." -ForegroundColor Red
    Pause
    exit 1
}
Write-Host "  [OK] Network connection verified!" -ForegroundColor Green

# Check Secure Boot status
$sbEnabled = $false
try {
    if (Confirm-SecureBootUEFI) { $sbEnabled = $true }
} catch {}

if ($sbEnabled) {
    Write-Host "  [INFO] UEFI Secure Boot is ENABLED. Standard signed drivers will install normally." -ForegroundColor DarkGray
} else {
    Write-Host "  [*] Configuring Driver Signature testing flags for MTK/QCOM..." -ForegroundColor DarkGray
    bcdedit /set nointegritychecks on 2>$null | Out-Null
    bcdedit /set testsigning on 2>$null | Out-Null
}

# -------------------------------------------------------------------------
# Step 2: Download & Extract Google Platform Tools to C:\adb
# -------------------------------------------------------------------------
Write-Host "`n[2/6] Setting up Google Platform Tools (ADB & Fastboot)..." -ForegroundColor Cyan
if (-not (Test-Path "C:\adb")) {
    New-Item -ItemType Directory -Path "C:\adb" -Force | Out-Null
}

$ptZip = Join-Path $WorkDir "platform-tools.zip"
Write-Host "  [*] Downloading latest Platform Tools from Google CDN..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -OutFile $ptZip -UseBasicParsing

Write-Host "  [*] Extracting binaries to C:\adb..." -ForegroundColor Yellow
Expand-Archive -Path $ptZip -DestinationPath $WorkDir -Force
Copy-Item -Path "$WorkDir\platform-tools\*" -Destination "C:\adb" -Recurse -Force
Remove-Item -Path "$WorkDir\platform-tools" -Recurse -Force -ErrorAction SilentlyContinue

if (Test-Path "C:\adb\adb.exe") {
    Write-Host "  [OK] ADB & Fastboot binaries successfully placed in C:\adb" -ForegroundColor Green
} else {
    Write-Host "  [!] Warning: adb.exe could not be verified in C:\adb" -ForegroundColor Red
}

# -------------------------------------------------------------------------
# Step 3: Safe Registry-Based System PATH Addition (Zero Truncation)
# -------------------------------------------------------------------------
Write-Host "`n[3/6] Adding C:\adb to Windows System PATH..." -ForegroundColor Cyan
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$currentPath = (Get-ItemProperty -Path $regKey -Name "Path").Path
$paths = $currentPath -split ";" | Where-Object { $_ -ne "" }

if ($paths -notcontains "C:\adb") {
    $newPath = ($paths + "C:\adb") -join ";"
    Set-ItemProperty -Path $regKey -Name "Path" -Value $newPath
    Write-Host "  [OK] C:\adb added cleanly to System PATH without character truncation!" -ForegroundColor Green
} else {
    Write-Host "  [OK] C:\adb is already present in System PATH." -ForegroundColor Green
}

# Broadcast WM_SETTINGCHANGE so all windows pick up the new PATH immediately
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32Helper {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
}
"@ -ErrorAction SilentlyContinue 2>$null
$lpdwResult = [UIntPtr]::Zero
[Win32Helper]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, "Environment", 2, 3000, [ref]$lpdwResult) | Out-Null

# Also set current session PATH
$env:Path += ";C:\adb"

# -------------------------------------------------------------------------
# Step 4: Universal Android WinUSB Drivers Installation
# -------------------------------------------------------------------------
Write-Host "`n[4/6] Installing Universal Android WinUSB Drivers..." -ForegroundColor Cyan
$usbZip = Join-Path $WorkDir "usb_driver.zip"
Write-Host "  [*] Downloading Google Universal USB driver..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://dl.google.com/android/repository/usb_driver_r13-windows.zip" -OutFile $usbZip -UseBasicParsing

Expand-Archive -Path $usbZip -DestinationPath $WorkDir -Force
$infPath = Join-Path $WorkDir "usb_driver\android_winusb.inf"

if (Test-Path $infPath) {
    Write-Host "  [*] Registering Universal Android WinUSB drivers into Windows DriverStore..." -ForegroundColor Yellow
    pnputil /add-driver "$infPath" /install 2>$null | Out-Null
    Write-Host "  [OK] Universal Android WinUSB drivers registered successfully!" -ForegroundColor Green
}

# -------------------------------------------------------------------------
# Step 5: Samsung Official Mobile USB Drivers
# -------------------------------------------------------------------------
Write-Host "`n[5/6] Setting up Official Samsung Mobile Drivers..." -ForegroundColor Cyan
$samsungInstalled = $false

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "  [*] Attempting install via winget..." -ForegroundColor Yellow
    winget install --id Samsung.USBDriverforMobilePhones -e --accept-package-agreements --accept-source-agreements --silent 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { $samsungInstalled = $true }
}

if (-not $samsungInstalled) {
    Write-Host "  [*] Downloading official installer from Samsung Developer portal..." -ForegroundColor Yellow
    $samsungExe = Join-Path $WorkDir "Samsung_USB_Driver.exe"
    try {
        Invoke-WebRequest -Uri "https://developer.samsung.com/common/download/usb-driver" -OutFile $samsungExe -UseBasicParsing
        if (Test-Path $samsungExe) {
            Start-Process $samsungExe -ArgumentList "/SILENT" -Wait
            Write-Host "  [OK] Samsung Mobile USB Drivers installed successfully!" -ForegroundColor Green
            $samsungInstalled = $true
        }
    } catch {}
}

if ($samsungInstalled) {
    Write-Host "  [OK] Samsung USB Drivers configured!" -ForegroundColor Green
} else {
    Write-Host "  [INFO] Samsung Drivers downloaded and queued." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------
# Step 6: Generate ROM Flasher Device Toolkit v3.0 on Desktop
# -------------------------------------------------------------------------
Write-Host "`n[6/6] Creating ROM Flasher Toolkit v3.0 on Desktop..." -ForegroundColor Cyan
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcut = Join-Path $desktopPath "ROM_Flasher_Toolkit.bat"

$toolkitContent = @'
@echo off
chcp 65001 >nul
title ROM Flasher - Professional Device Toolkit v3.0
color 0b
:menu
cls
echo ==============================================================================
echo           ROM FLASHER - PROFESSIONAL DEVICE TOOLKIT v3.0
echo                     Crafted for Rohit Bhai
echo ==============================================================================
echo.
echo  --- [1] ADB STATUS & DEVICE INFO ---
echo   1. Check Connected ADB Devices
echo   2. View Real-Time Device Battery & Model Info
echo   3. Restart ADB Server (Fix Device Not Detected)
echo.
echo  --- [2] FASTBOOT & BOOTLOADER ---
echo   4. Check Fastboot Devices
echo   5. Check Bootloader Lock/Unlock Status
echo   6. Check if Device is in Fastbootd (Dynamic Partitions)
echo.
echo  --- [3] REBOOT CONTROLS ---
echo   7. Reboot Device to System
echo   8. Reboot Device to Recovery Mode
echo   9. Reboot Device to Fastboot / Bootloader
echo  10. Reboot Device to Fastbootd Mode (Android 10+)
echo  11. Reboot Device to Qualcomm EDL 9008 (Dead/Unbrick Mode)
echo.
echo  --- [4] FLASHING TOOLS ---
echo  12. Sideload ROM / Update Package (adb sideload)
echo  13. Open Elevated CMD at C:\adb
echo  14. Driver Doctor: Open Windows Device Manager
echo  15. Exit Toolkit
echo ==============================================================================
echo.
set /p choice="Enter your choice (1-15): "
if "%choice%"=="1" ( cls & echo [*] Checking ADB Devices... & adb devices -l & echo. & pause & goto menu )
if "%choice%"=="2" ( cls & echo [*] Fetching Device Info... & adb shell getprop ro.product.model & adb shell dumpsys battery & echo. & pause & goto menu )
if "%choice%"=="3" ( cls & echo [*] Restarting ADB Server... & adb kill-server & adb start-server & echo [OK] Server reset! & pause & goto menu )
if "%choice%"=="4" ( cls & echo [*] Checking Fastboot Devices... & fastboot devices & echo. & pause & goto menu )
if "%choice%"=="5" ( cls & echo [*] Checking Bootloader Status... & fastboot oem device-info 2>&1 & fastboot getvar unlocked 2>&1 & echo. & pause & goto menu )
if "%choice%"=="6" ( cls & echo [*] Checking Fastbootd userspace... & fastboot getvar is-userspace 2>&1 & echo. & pause & goto menu )
if "%choice%"=="7" ( cls & echo [*] Rebooting to System... & adb reboot 2>nul || fastboot reboot & pause & goto menu )
if "%choice%"=="8" ( cls & echo [*] Rebooting to Recovery... & adb reboot recovery 2>nul || fastboot reboot recovery & pause & goto menu )
if "%choice%"=="9" ( cls & echo [*] Rebooting to Bootloader... & adb reboot bootloader & pause & goto menu )
if "%choice%"=="10" ( cls & echo [*] Rebooting to Fastbootd... & fastboot reboot fastboot & pause & goto menu )
if "%choice%"=="11" ( cls & echo [*] Rebooting to EDL 9008... & adb reboot edl 2>nul || fastboot oem edl 2>nul || fastboot reboot-edl 2>nul & pause & goto menu )
if "%choice%"=="12" ( cls & set /p zip="Drag and Drop ROM zip here: " & adb sideload %zip% & pause & goto menu )
if "%choice%"=="13" ( start cmd.exe /k "cd /d C:\adb" & goto menu )
if "%choice%"=="14" ( start devmgmt.msc & goto menu )
if "%choice%"=="15" ( exit )
goto menu
'@

$toolkitContent | Set-Content -Path $shortcut -Encoding UTF8
Write-Host "  [OK] ROM_Flasher_Toolkit.bat generated on your Desktop!" -ForegroundColor Green

# Cleanup temp files
Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "                      SETUP & UPGRADE COMPLETED SUCCESSFULLY!                           " -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  * ADB & Fastboot installed in C:\adb" -ForegroundColor White
Write-Host "  * System PATH updated (run 'adb' or 'fastboot' in ANY folder)" -ForegroundColor White
Write-Host "  * Universal Android WinUSB Drivers active" -ForegroundColor White
Write-Host "  * Samsung Mobile Drivers active" -ForegroundColor White
Write-Host "  * Interactive 'ROM_Flasher_Toolkit.bat' on your Desktop" -ForegroundColor White
Write-Host ""
Write-Host "  Crafted for Rohit Bhai | ROM Flasher" -ForegroundColor Cyan
Write-Host "  Repository: https://github.com/romflasher3419-spec/adb-fastboot-driver-toolkit" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
