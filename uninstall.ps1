# ==============================================================================
# ROM Flasher - Universal Phone Driver and ADB Uninstaller
# Target: Windows 11 / Windows 10
# Crafted for Rohit Bhai
# ==============================================================================

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Clear-Host
Write-Host "====================================================================" -ForegroundColor Yellow
Write-Host "       ROM FLASHER - ADB AND PHONE DRIVER CLEAN RESET               " -ForegroundColor Yellow
Write-Host "====================================================================" -ForegroundColor Yellow
Write-Host ""

# 1. Stop ADB Server if running
Write-Host "[*] Stopping ADB server if running..." -ForegroundColor Cyan
Stop-Process -Name adb -Force -ErrorAction SilentlyContinue

# 2. Remove C:\adb from System PATH
Write-Host "[*] Removing C:\adb from System PATH..." -ForegroundColor Cyan
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$currentPath = (Get-ItemProperty -Path $regKey -Name "Path").Path
$paths = $currentPath -split ";" | Where-Object { $_ -ne "" -and $_ -ne "C:\adb" }
$newPath = $paths -join ";"
Set-ItemProperty -Path $regKey -Name "Path" -Value $newPath

# Broadcast environment change
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinResetHelper {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
}
"@ -ErrorAction SilentlyContinue 2>$null
$lpdwResult = [UIntPtr]::Zero
[WinResetHelper]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, "Environment", 2, 3000, [ref]$lpdwResult) | Out-Null

# 3. Remove C:\adb Directory
if (Test-Path "C:\adb") {
    Write-Host "[*] Deleting C:\adb folder..." -ForegroundColor Cyan
    Remove-Item -Path "C:\adb" -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. Remove any desktop shortcut if lingering
$desktopLocations = @(
    [Environment]::GetFolderPath("Desktop"),
    (Join-Path $env:USERPROFILE "Desktop"),
    (Join-Path $env:USERPROFILE "OneDrive\Desktop")
)
foreach ($desk in $desktopLocations) {
    if (Test-Path "$desk\ROM_Flasher_Toolkit.bat") {
        Write-Host "[*] Removing Desktop shortcut from $desk..." -ForegroundColor Cyan
        Remove-Item "$desk\ROM_Flasher_Toolkit.bat" -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "[OK] ADB and paths cleaned up successfully!" -ForegroundColor Green
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
