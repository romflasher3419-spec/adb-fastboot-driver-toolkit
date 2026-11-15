<#
.SYNOPSIS
    ROM Flasher - Uninstaller & Clean Reset
.DESCRIPTION
    Safely removes C:\adb from the system, cleans the System PATH environment variable,
    and removes the Desktop Toolkit shortcut.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Clear-Host
Write-Host "====================================================================" -ForegroundColor Yellow
Write-Host "        ROM FLASHER - ADB & FASTBOOT DRIVER UNINSTALLER            " -ForegroundColor Yellow
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

# 3. Remove C:\adb Directory
if (Test-Path "C:\adb") {
    Write-Host "[*] Deleting C:\adb folder..." -ForegroundColor Cyan
    Remove-Item -Path "C:\adb" -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. Remove Desktop Toolkit Shortcut
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcut = Join-Path $desktop "ROM_Flasher_Toolkit.bat"
if (Test-Path $shortcut) {
    Write-Host "[*] Removing Desktop shortcut..." -ForegroundColor Cyan
    Remove-Item -Path $shortcut -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "[OK] ADB & Fastboot uninstalled cleanly!" -ForegroundColor Green
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
