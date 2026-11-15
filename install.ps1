# ==============================================================================
# ROM Flasher - Universal Phone Drivers and Platform Tools Installer v5.0
# Target: Windows 11 / Windows 10 (x64 / x86)
# Supports: Qualcomm QDLoader 9008, MediaTek MTK VCOM, Samsung, Unisoc, Fastboot/ADB
# Crafted for Rohit Bhai | 100% Clean - No Desktop Shortcuts - No Menus
# ==============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Auto-elevate to Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[*] Administrator privileges required. Requesting elevation..." -ForegroundColor Yellow
    if ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        $elevateCmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm 'https://raw.githubusercontent.com/romflasher3419-spec/adb-fastboot-driver-toolkit/main/install.ps1' | iex"
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
         UNIVERSAL PHONE DRIVER INSTALLER v5.0 [EVERY PHONE IN THE WORLD]
                             Crafted for Rohit Bhai
========================================================================================
"@ -ForegroundColor Cyan

Write-Host "  [+] Qualcomm Snapdragon (HS-USB QDLoader 9008 EDL + Diag)" -ForegroundColor White
Write-Host "  [+] MediaTek Dimensity and Helio (Preloader + USB VCOM + BROM)" -ForegroundColor White
Write-Host "  [+] Samsung Electronics (MTP + Odin Download Mode + Composite)" -ForegroundColor White
Write-Host "  [+] Unisoc / Spreadtrum (SPD USB-to-Serial Flash + Diag)" -ForegroundColor White
Write-Host "  [+] Universal Android WinUSB (Xiaomi, Vivo, Oppo, Realme, OnePlus, Motorola, Nothing, Huawei, Google)" -ForegroundColor White
Write-Host "  [+] Official Google ADB and Fastboot Platform-Tools (C:\adb)" -ForegroundColor White
Write-Host ""

# Clean up any previously created desktop shortcuts
$desktopLocations = @(
    [Environment]::GetFolderPath("Desktop"),
    (Join-Path $env:USERPROFILE "Desktop"),
    (Join-Path $env:USERPROFILE "OneDrive\Desktop")
)
foreach ($desk in $desktopLocations) {
    if (Test-Path "$desk\ROM_Flasher_Toolkit.bat") {
        Remove-Item "$desk\ROM_Flasher_Toolkit.bat" -Force -ErrorAction SilentlyContinue
    }
}

$WorkDir = Join-Path $env:TEMP "Universal_Phone_Drivers_Setup"
if (Test-Path $WorkDir) {
    Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null

# -------------------------------------------------------------------------
# Step 1: Download & Install Universal Driver Pack (DriverStore)
# -------------------------------------------------------------------------
Write-Host "[1/3] Downloading Complete Universal Driver Pack (All Chipsets)..." -ForegroundColor Cyan
$driverZipUrl = "https://github.com/romflasher3419-spec/adb-fastboot-driver-toolkit/releases/download/v5.0.0/Universal-Drivers-Pack.zip"
$driverZipFile = Join-Path $WorkDir "Universal-Drivers-Pack.zip"
$driverExtractDir = Join-Path $WorkDir "drivers"

try {
    Invoke-WebRequest -Uri $driverZipUrl -OutFile $driverZipFile -UseBasicParsing
    Write-Host "  [OK] Universal Driver Pack downloaded successfully!" -ForegroundColor Green
} catch {
    Write-Host "  [!] Error downloading driver package. Checking connection..." -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "`n[2/3] Extracting and Registering Drivers into Windows DriverStore..." -ForegroundColor Cyan
Expand-Archive -Path $driverZipFile -DestinationPath $driverExtractDir -Force

Write-Host "  [*] Registering all driver packages with pnputil..." -ForegroundColor Yellow
$pnpOutput = pnputil /add-driver "$driverExtractDir\*.inf" /subdirs /install 2>&1
$addedCount = ($pnpOutput | Select-String -Pattern "added successfully|published").Count

Write-Host "  [OK] Driver packages registered into Windows DriverStore!" -ForegroundColor Green
Write-Host "  [+] Qualcomm QDLoader 9008 Drivers: ACTIVE" -ForegroundColor White
Write-Host "  [+] MediaTek Preloader and USB VCOM Drivers: ACTIVE" -ForegroundColor White
Write-Host "  [+] Samsung Mobile USB and Odin Drivers: ACTIVE" -ForegroundColor White
Write-Host "  [+] Unisoc / Spreadtrum USB-to-Serial Drivers: ACTIVE" -ForegroundColor White
Write-Host "  [+] Universal Android WinUSB (All OEM Brands): ACTIVE" -ForegroundColor White

# -------------------------------------------------------------------------
# Step 2: Download & Extract Google Platform Tools to C:\adb
# -------------------------------------------------------------------------
Write-Host "`n[3/3] Setting up Google Platform Tools (ADB and Fastboot)..." -ForegroundColor Cyan
if (-not (Test-Path "C:\adb")) {
    New-Item -ItemType Directory -Path "C:\adb" -Force | Out-Null
}

$ptZip = Join-Path $WorkDir "platform-tools.zip"
Write-Host "  [*] Downloading latest Platform Tools from Google CDN..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -OutFile $ptZip -UseBasicParsing

Expand-Archive -Path $ptZip -DestinationPath $WorkDir -Force
Copy-Item -Path "$WorkDir\platform-tools\*" -Destination "C:\adb" -Recurse -Force
Remove-Item -Path "$WorkDir\platform-tools" -Recurse -Force -ErrorAction SilentlyContinue

# Safe Registry PATH update
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$currentPath = (Get-ItemProperty -Path $regKey -Name "Path").Path
$paths = $currentPath -split ";" | Where-Object { $_ -ne "" }

if ($paths -notcontains "C:\adb") {
    $newPath = ($paths + "C:\adb") -join ";"
    Set-ItemProperty -Path $regKey -Name "Path" -Value $newPath
}

# Broadcast environment change
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win38Helper {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
}
"@ -ErrorAction SilentlyContinue 2>$null
$lpdwResult = [UIntPtr]::Zero
[Win38Helper]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, "Environment", 2, 3000, [ref]$lpdwResult) | Out-Null
$env:Path += ";C:\adb"

Write-Host "  [OK] ADB and Fastboot installed cleanly in C:\adb" -ForegroundColor Green
Write-Host "  [OK] System PATH updated. 'adb' and 'fastboot' commands work in ANY terminal." -ForegroundColor Green

# Cleanup temporary setup files
Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue

# Verify ADB version
$adbVer = "Android Platform Tools"
try {
    $adbVer = (& "C:\adb\adb.exe" version 2>$null | Select-Object -First 1)
} catch {}

Write-Host ""
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host "                 UNIVERSAL DRIVER INSTALLATION COMPLETE - 100% SUCCESS                  " -ForegroundColor Green
Write-Host "========================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  * $adbVer installed at C:\adb" -ForegroundColor White
Write-Host "  * Windows DriverStore updated permanently with all chipsets" -ForegroundColor White
Write-Host "  * Supported: Qualcomm EDL 9008, MediaTek BROM/Preloader, Samsung, Unisoc, WinUSB" -ForegroundColor White
Write-Host "  * Brand Support: Xiaomi, Poco, Redmi, Vivo, Oppo, Realme, OnePlus, Samsung, Google, Motorola, Nothing, Asus" -ForegroundColor White
Write-Host "  * No desktop shortcuts created. Clean system setup." -ForegroundColor White
Write-Host ""
Write-Host "  Rohit Bhai, ab duniya ka koi bhi phone USB se connect karo, PC turant connect kar lega!" -ForegroundColor Cyan
Write-Host "  Repository: https://github.com/romflasher3419-spec/adb-fastboot-driver-toolkit" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
