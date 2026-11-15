@echo off
chcp 65001 >nul
title Universal Phone Driver Installer v5.0 - Rohit Bhai
color 0b

:: ==============================================================================
:: Universal Phone Driver Installer v5.0
:: Automated Silent Setup - No Desktop Shortcuts - No Menus
:: Target: Windows 11 / Windows 10 (x64 / x86)
:: Crafted for Rohit Bhai | ROM Flasher
:: ==============================================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Requesting Administrator Privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
echo [*] Launching Universal Phone Driver Installation...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm 'https://raw.githubusercontent.com/romflasher3419-spec/adb-fastboot-driver-toolkit/main/install.ps1' | iex"
)
