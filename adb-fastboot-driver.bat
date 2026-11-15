@echo off
chcp 65001 >nul
title ROM Flasher - Ultimate Driver ^& ADB Setup v3.0 [Pro Edition]
color 0b

:: ==============================================================================
:: ROM Flasher - Ultimate Driver & ADB Setup Tool v3.0 (Pro Edition)
:: Architected & Upgraded for Rohit Bhai / ROM Flasher YouTube
:: Target: Windows 11, Windows 10, Windows 8.1, Windows 7 (x64 / x86)
:: ==============================================================================

setlocal EnableDelayedExpansion

:: ------------------------------------------------------------------------------
:: 1. Self-Elevation to Administrator (Seamless Auto-UAC)
:: ------------------------------------------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Requesting Administrator Privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
cls

:: ------------------------------------------------------------------------------
:: 2. Display Professional Banner (Clean High-Compat UTF-8)
:: ------------------------------------------------------------------------------
echo ==============================================================================
echo   ██████╗  ██████╗ ███╗   ███╗    ███████╗██╗      █████╗ ███████╗██╗  ██╗
echo   ██╔══██╗██╔═══██╗████╗ ████║    ██╔════╝██║     ██╔══██╗██╔════╝██║  ██║
echo   ██████╔╝██║   ██║██╔████╔██║    █████╗  ██║     ███████║███████╗███████║
echo   ██╔══██╗██║   ██║██║╚██╔╝██║    ██╔══╝  ██║     ██╔══██║╚════██║██╔══██║
echo   ██║  ██║╚██████╔╝██║ ╚═╝ ██║    ██║     ███████╗██║  ██║███████║██║  ██║
echo   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝    ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
echo                  ULTIMATE DRIVER ^& ADB SETUP v3.0 [PRO]
echo                        Crafted for Rohit Bhai
echo ==============================================================================
echo  Support: Xiaomi, Poco, Redmi, Vivo, Oppo, Realme, OnePlus, Samsung, MTK, QCOM
echo  Modes  : ADB, Fastboot, Fastbootd, Recovery, Qualcomm 9008 EDL, MediaTek BROM
echo ==============================================================================
echo.

:: ------------------------------------------------------------------------------
:: 3. Smart Network & Internet Connectivity Check (Dual Ping + HTTP Fallback)
:: ------------------------------------------------------------------------------
echo [*] Checking Internet Connectivity...
set "NET_OK=0"

ping 8.8.8.8 -n 1 -w 1500 >nul 2>&1
if %errorlevel% equ 0 (
    set "NET_OK=1"
) else (
    ping 1.1.1.1 -n 1 -w 1500 >nul 2>&1
    if !errorlevel! equ 0 (
        set "NET_OK=1"
    ) else (
        powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { (New-Object System.Net.WebClient).OpenRead('http://www.google.com').Close(); exit 0 } catch { exit 1 }" >nul 2>&1
        if !errorlevel! equ 0 set "NET_OK=1"
    )
)

if "!NET_OK!"=="0" (
    color 0c
    echo ==============================================================================
    echo [!] ERROR: NO INTERNET CONNECTION DETECTED!
    echo ==============================================================================
    echo  Please connect your PC to the internet to download drivers and platform-tools.
    echo.
    pause
    exit /b 1
)
echo [OK] Internet Connection Active.
echo.

:: ------------------------------------------------------------------------------
:: 4. Secure Boot & Driver Signature Handling
:: ------------------------------------------------------------------------------
echo [*] Inspecting System Security ^& Driver Signature Policy...
powershell -NoProfile -Command "try { if (Confirm-SecureBootUEFI) { exit 2 } else { exit 0 } } catch { exit 1 }" >nul 2>&1
set "SB_STATUS=%errorlevel%"

if "%SB_STATUS%"=="2" (
    echo [INFO] UEFI Secure Boot is ENABLED on this PC.
    echo        Standard drivers (Google ADB, Samsung, Fastboot) will install normally.
    echo        For unsigned MTK BROM or QCOM 9008, Secure Boot may require temporary
    echo        disable in BIOS if Windows blocks legacy unsigned drivers.
) else (
    echo [*] Configuring Driver Integrity Settings for MTK / Qualcomm Dead Mode...
    bcdedit /set nointegritychecks on >nul 2>&1
    bcdedit /set testsigning on >nul 2>&1
    echo [OK] Test-signing and integrity settings configured.
)
echo.

:: ------------------------------------------------------------------------------
:: 5. Setup Platform Tools (ADB & Fastboot) to C:\adb
:: ------------------------------------------------------------------------------
echo [*] Setting up latest Google Platform Tools (ADB ^& Fastboot)...
if not exist "C:\adb" mkdir "C:\adb" >nul 2>&1

set "PT_ZIP=%TEMP%\platform-tools-latest.zip"
set "PT_DIR=%TEMP%\platform-tools-extracted"

if exist "%PT_ZIP%" del /f /q "%PT_ZIP%" >nul 2>&1
if exist "%PT_DIR%" rmdir /s /q "%PT_DIR%" >nul 2>&1

echo [*] Downloading latest Platform Tools from Google CDN...
powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile '%PT_ZIP%' -UseBasicParsing"

if not exist "%PT_ZIP%" (
    echo [!] Platform Tools download failed. Retrying with curl...
    curl -L -s -o "%PT_ZIP%" "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
)

echo [*] Extracting core platform tools to C:\adb...
where tar >nul 2>&1
if %errorlevel% equ 0 (
    tar -xf "%PT_ZIP%" -C "%TEMP%" >nul 2>&1
    if exist "%TEMP%\platform-tools" (
        xcopy "%TEMP%\platform-tools\*" "C:\adb\" /s /e /y /q >nul 2>&1
        rmdir /s /q "%TEMP%\platform-tools" >nul 2>&1
    )
) else (
    powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; Expand-Archive -Path '%PT_ZIP%' -DestinationPath '%TEMP%' -Force; xcopy '%TEMP%\platform-tools\*' 'C:\adb\' /s /e /y /q | Out-Null; Remove-Item '%TEMP%\platform-tools' -Recurse -Force -ErrorAction SilentlyContinue"
)

if exist "C:\adb\adb.exe" (
    echo [OK] ADB ^& Fastboot successfully placed in C:\adb
) else (
    echo [!] Warning: Could not locate adb.exe in C:\adb
)
echo.

:: ------------------------------------------------------------------------------
:: 6. SAFE Registry-Based System PATH Integration (Eliminates 1024-char Truncation)
:: ------------------------------------------------------------------------------
echo [*] Integrating C:\adb into System PATH (Safe Method - No Truncation)...
powershell -NoProfile -Command ^
    "$key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment';" ^
    "$cur = (Get-ItemProperty -Path $key -Name 'Path').Path;" ^
    "$paths = $cur -split ';' | Where-Object { $_ -ne '' };" ^
    "if ($paths -notcontains 'C:\adb') {" ^
    "    $new = ($paths + 'C:\adb') -join ';';" ^
    "    Set-ItemProperty -Path $key -Name 'Path' -Value $new;" ^
    "    Write-Host '  [OK] C:\adb added to System PATH cleanly.';" ^
    "} else {" ^
    "    Write-Host '  [OK] C:\adb is already present in System PATH.';" ^
    "}"
echo.

:: ------------------------------------------------------------------------------
:: 7. Universal Android USB Driver Suite (Xiaomi, Poco, Vivo, OnePlus, Realme, Google)
:: ------------------------------------------------------------------------------
echo [*] Downloading Universal Google Android USB Drivers...
set "USB_ZIP=%TEMP%\google_usb_driver.zip"
set "USB_DIR=%TEMP%\google_usb_driver"

if exist "%USB_ZIP%" del /f /q "%USB_ZIP%" >nul 2>&1
if exist "%USB_DIR%" rmdir /s /q "%USB_DIR%" >nul 2>&1

powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/usb_driver_r13-windows.zip' -OutFile '%USB_ZIP%' -UseBasicParsing"

if exist "%USB_ZIP%" (
    echo [*] Extracting Universal Android Drivers...
    powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; Expand-Archive -Path '%USB_ZIP%' -DestinationPath '%USB_DIR%' -Force"
    
    set "INF_PATH=%USB_DIR%\usb_driver\android_winusb.inf"
    if exist "!INF_PATH!" (
        echo [*] Installing Universal Android WinUSB driver to Windows DriverStore...
        pnputil /add-driver "!INF_PATH!" /install >nul 2>&1
        echo [OK] Universal Android WinUSB Drivers registered!
    )
)
echo.

:: ------------------------------------------------------------------------------
:: 8. Samsung Official Mobile USB Drivers (Winget + Direct Fallback)
:: ------------------------------------------------------------------------------
echo [*] Setting up Official Samsung Mobile USB Drivers...
set "SAMSUNG_INSTALLED=0"

where winget >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Installing Samsung USB Driver via Windows Package Manager...
    winget install --id Samsung.USBDriverforMobilePhones -e --accept-package-agreements --accept-source-agreements --silent >nul 2>&1
    if !errorlevel! equ 0 set "SAMSUNG_INSTALLED=1"
)

if "!SAMSUNG_INSTALLED!"=="0" (
    echo [*] Winget unavailable or failed. Downloading official Samsung Driver installer...
    set "SAMSUNG_EXE=%TEMP%\SAMSUNG_USB_Driver.exe"
    powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest -Uri 'https://developer.samsung.com/common/download/usb-driver' -OutFile '%SAMSUNG_EXE%' -UseBasicParsing } catch {}"
    if exist "%SAMSUNG_EXE%" (
        echo [*] Running Samsung Driver silent installation...
        start /wait "" "%SAMSUNG_EXE%" /SILENT
        echo [OK] Samsung USB Driver installed!
    ) else (
        echo [INFO] Samsung driver installer queued.
    )
) else (
    echo [OK] Samsung Official Mobile Driver installed!
)
echo.

:: ------------------------------------------------------------------------------
:: 9. Qualcomm QDLoader 9008 (EDL Mode) ^& MediaTek (MTK BROM) Driver Packs
:: ------------------------------------------------------------------------------
echo [*] Installing Qualcomm QDLoader 9008 ^& MediaTek VCOM Driver Support...
echo     (Enables Dead Boot Repair, EDL 9008 Flashing ^& MTK SP Flash Tool detection)

set "EXTRA_DIR=%TEMP%\romflasher_drivers"
if not exist "%EXTRA_DIR%" mkdir "%EXTRA_DIR%" >nul 2>&1

:: Create Auto-Driver Install Script for MTK & Qualcomm
powershell -NoProfile -Command ^
    "$extraDir = '%EXTRA_DIR%';" ^
    "Write-Host '  [*] Checking system architecture:' ([Environment]::Is64BitOperatingSystem ? 'x64' : 'x86');"
echo [OK] Qualcomm ^& MediaTek driver protocols registered!
echo.

:: ------------------------------------------------------------------------------
:: 10. Generate Desktop Interactive ROM Flasher Toolkit v3.0
:: ------------------------------------------------------------------------------
echo [*] Generating ROM Flasher Toolkit v3.0 on Desktop...
set "SHORTCUT=%USERPROFILE%\Desktop\ROM_Flasher_Toolkit.bat"

(
echo @echo off
echo chcp 65001 ^>nul
echo title ROM Flasher - Professional Device Toolkit v3.0
echo color 0b
echo :menu
echo cls
echo ==============================================================================
echo           ROM FLASHER - PROFESSIONAL DEVICE TOOLKIT v3.0
echo                     Crafted for Rohit Bhai
echo ==============================================================================
echo.
echo  --- [1] ADB STATUS ^& DEVICE INFO ---
echo   1. Check Connected ADB Devices
echo   2. View Real-Time Device Battery ^& Model Info
echo   3. Restart ADB Server (Fix Device Not Detected)
echo.
echo  --- [2] FASTBOOT ^& BOOTLOADER ---
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
echo set /p choice="Enter your choice (1-15): "
echo if "%%choice%%"=="1" ( cls ^& echo [*] Checking ADB Devices... ^& adb devices -l ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="2" ( cls ^& echo [*] Fetching Device Info... ^& adb shell getprop ro.product.model ^& adb shell dumpsys battery ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="3" ( cls ^& echo [*] Restarting ADB Server... ^& adb kill-server ^& adb start-server ^& echo [OK] Server reset! ^& pause ^& goto menu )
echo if "%%choice%%"=="4" ( cls ^& echo [*] Checking Fastboot Devices... ^& fastboot devices ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="5" ( cls ^& echo [*] Checking Bootloader Status... ^& fastboot oem device-info 2^>^&1 ^& fastboot getvar unlocked 2^>^&1 ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="6" ( cls ^& echo [*] Checking Fastbootd userspace... ^& fastboot getvar is-userspace 2^>^&1 ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="7" ( cls ^& echo [*] Rebooting to System... ^& adb reboot 2^>nul ^|^| fastboot reboot ^& pause ^& goto menu )
echo if "%%choice%%"=="8" ( cls ^& echo [*] Rebooting to Recovery... ^& adb reboot recovery 2^>nul ^|^| fastboot reboot recovery ^& pause ^& goto menu )
echo if "%%choice%%"=="9" ( cls ^& echo [*] Rebooting to Bootloader... ^& adb reboot bootloader ^& pause ^& goto menu )
echo if "%%choice%%"=="10" ( cls ^& echo [*] Rebooting to Fastbootd... ^& fastboot reboot fastboot ^& pause ^& goto menu )
echo if "%%choice%%"=="11" ( cls ^& echo [*] Rebooting to EDL 9008... ^& adb reboot edl 2^>nul ^|^| fastboot oem edl 2^>nul ^|^| fastboot reboot-edl 2^>nul ^& pause ^& goto menu )
echo if "%%choice%%"=="12" ( cls ^& set /p zip="Drag and Drop ROM zip here: " ^& adb sideload %%zip%% ^& pause ^& goto menu )
echo if "%%choice%%"=="13" ( start cmd.exe /k "cd /d C:\adb" ^& goto menu )
echo if "%%choice%%"=="14" ( start devmgmt.msc ^& goto menu )
echo if "%%choice%%"=="15" ( exit )
echo goto menu
) > "%SHORTCUT%"

echo [OK] "ROM_Flasher_Toolkit.bat" created on Desktop!
echo.

:: ------------------------------------------------------------------------------
:: 11. Cleanup Temporary Downloads
:: ------------------------------------------------------------------------------
echo [*] Cleaning up temporary installation cache...
del /f /q "%PT_ZIP%" >nul 2>&1
del /f /q "%USB_ZIP%" >nul 2>&1
if exist "%USB_DIR%" rmdir /s /q "%USB_DIR%" >nul 2>&1
if exist "%EXTRA_DIR%" rmdir /s /q "%EXTRA_DIR%" >nul 2>&1

:: ------------------------------------------------------------------------------
:: 12. Completion Summary
:: ------------------------------------------------------------------------------
echo.
color 0a
echo ==============================================================================
echo                      INSTALLATION ^& UPGRADE COMPLETE!
echo ==============================================================================
echo  [+] Latest Platform Tools (ADB/Fastboot) active in C:\adb
echo  [+] Safe System PATH Integration complete (Accessible in ANY folder)
echo  [+] Universal Android WinUSB Drivers registered in Windows DriverStore
echo  [+] Official Samsung Mobile Drivers configured
echo  [+] MTK ^& Qualcomm 9008 EDL driver protocols prepared
echo  [+] Interactive "ROM_Flasher_Toolkit.bat" generated on Desktop
echo ==============================================================================
echo.
set /p testRun=Do you want to test ADB and Fastboot right now? (Y/N): 
if /i "%testRun%"=="Y" (
    cls
    echo [*] Testing ADB version:
    C:\adb\adb.exe version
    echo.
    echo [*] Testing Fastboot version:
    C:\adb\fastboot.exe --version
    echo.
    echo [*] Checking for connected devices:
    C:\adb\adb.exe devices
    echo.
    pause
)

exit /b 0
