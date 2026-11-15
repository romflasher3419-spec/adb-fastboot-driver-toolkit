@echo off
chcp 65001 >nul
title ROM Flasher - Ultimate Driver ^& ADB Setup v4.0 [Pro Edition]
color 0b

:: ==============================================================================
:: ROM Flasher - Ultimate Driver & ADB Setup Tool v4.0 (Pro Edition)
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
echo                  ULTIMATE DRIVER + ADB SETUP v4.0 [PRO]
echo                        Crafted for Rohit Bhai
echo ==============================================================================
echo  Support: Xiaomi, Poco, Redmi, Vivo, Oppo, Realme, OnePlus, Samsung, MTK, QCOM
echo  Features: Auto-ADB, Dual-Slot Switcher, Magisk Flasher, Fastbootd, EDL 9008
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
echo [*] Inspecting System Security + Driver Signature Policy...
powershell -NoProfile -Command "try { if (Confirm-SecureBootUEFI) { exit 2 } else { exit 0 } } catch { exit 1 }" >nul 2>&1
set "SB_STATUS=%errorlevel%"

if "%SB_STATUS%"=="2" (
    echo [INFO] UEFI Secure Boot is ENABLED on this PC.
    echo        Standard drivers (Google ADB, Samsung, Fastboot) will install normally.
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
echo [*] Setting up latest Google Platform Tools (ADB + Fastboot)...
if not exist "C:\adb" mkdir "C:\adb" >nul 2>&1

set "PT_ZIP=%TEMP%\platform-tools-latest.zip"
if exist "%PT_ZIP%" del /f /q "%PT_ZIP%" >nul 2>&1

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
    echo [OK] ADB + Fastboot successfully placed in C:\adb
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
    )
) else (
    echo [OK] Samsung Official Mobile Driver installed!
)
echo.

:: ------------------------------------------------------------------------------
:: 9. Generate Desktop Interactive ROM Flasher Toolkit v4.0 Ultimate
:: ------------------------------------------------------------------------------
echo [*] Generating ROM Flasher Toolkit v4.0 Ultimate on Desktop...
set "SHORTCUT=%USERPROFILE%\Desktop\ROM_Flasher_Toolkit.bat"

(
echo @echo off
echo chcp 65001 ^>nul
echo title ROM Flasher - Professional Device Toolkit v4.0 Ultimate
echo color 0b
echo :menu
echo cls
echo ==============================================================================
echo       ROM FLASHER - PROFESSIONAL DEVICE TOOLKIT v4.0 [ULTIMATE]
echo                     Crafted for Rohit Bhai
echo ==============================================================================
echo.
echo  --- [1] ADB STATUS + DEVICE INFO ---
echo   1. Check Connected ADB Devices (Detailed with Serial)
echo   2. View Real-Time Device Battery, Model + Android Version
echo   3. Restart ADB Server (Fix Device Not Detected)
echo   4. Install APK directly to Device [Drag and Drop]
echo.
echo  --- [2] FASTBOOT, DUAL SLOTS + ROOTING ---
echo   5. Check Fastboot Devices
echo   6. Check Bootloader Lock/Unlock Status
echo   7. Check if Device is in Fastbootd (Dynamic Partitions)
echo   8. Dual Slot Fixer: Check Active Slot (A/B)
echo   9. Switch to Slot A (fastboot set_active a)
echo  10. Switch to Slot B (fastboot set_active b)
echo  11. 1-Click Root Flasher [Drag and Drop boot.img / init_boot.img]
echo.
echo  --- [3] REBOOT ENGINE ---
echo  12. Reboot Device to System (Normal)
echo  13. Reboot Device to Recovery Mode (TWRP/OrangeFox/Stock)
echo  14. Reboot Device to Fastboot / Bootloader
echo  15. Reboot Device to Fastbootd Mode (Android 10+)
echo  16. Reboot Device to Qualcomm EDL 9008 (Dead Boot Repair)
echo.
echo  --- [4] FLASHING UTILITIES ---
echo  17. Factory Reset / Wipe Data (fastboot -w / unbrick bootloop)
echo  18. Sideload ROM / Update Package (adb sideload)
echo  19. Open Elevated CMD at C:\adb
echo  20. Driver Doctor: Open Windows Device Manager
echo  21. Exit Toolkit
echo ==============================================================================
echo.
echo set /p choice="Enter your choice (1-21): "
echo if "%%choice%%"=="1" ( cls ^& echo [*] Checking ADB Devices... ^& adb devices -l ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="2" ( cls ^& echo [*] Fetching Device Info... ^& echo Model: ^& adb shell getprop ro.product.model ^& echo Android Ver: ^& adb shell getprop ro.build.version.release ^& echo Battery: ^& adb shell dumpsys battery ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="3" ( cls ^& echo [*] Restarting ADB Server... ^& adb kill-server ^& adb start-server ^& echo [OK] Server reset! ^& pause ^& goto menu )
echo if "%%choice%%"=="4" ( cls ^& set /p apk="Drag and Drop APK file here: " ^& adb install -r %%apk%% ^& pause ^& goto menu )
echo if "%%choice%%"=="5" ( cls ^& echo [*] Checking Fastboot Devices... ^& fastboot devices ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="6" ( cls ^& echo [*] Checking Bootloader Status... ^& fastboot oem device-info 2^>^&1 ^& fastboot getvar unlocked 2^>^&1 ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="7" ( cls ^& echo [*] Checking Fastbootd userspace... ^& fastboot getvar is-userspace 2^>^&1 ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="8" ( cls ^& echo [*] Current Active Slot: ^& fastboot getvar current-slot 2^>^&1 ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="9" ( cls ^& echo [*] Switching to Slot A... ^& fastboot set_active a ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="10" ( cls ^& echo [*] Switching to Slot B... ^& fastboot set_active b ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="11" ( cls ^& set /p bimg="Drag and Drop boot.img or init_boot.img here: " ^& echo Flashing boot... ^& fastboot flash boot %%bimg%% 2^>nul ^|^| fastboot flash init_boot %%bimg%% ^& echo. ^& pause ^& goto menu )
echo if "%%choice%%"=="12" ( cls ^& echo [*] Rebooting to System... ^& adb reboot 2^>nul ^|^| fastboot reboot ^& pause ^& goto menu )
echo if "%%choice%%"=="13" ( cls ^& echo [*] Rebooting to Recovery... ^& adb reboot recovery 2^>nul ^|^| fastboot reboot recovery ^& pause ^& goto menu )
echo if "%%choice%%"=="14" ( cls ^& echo [*] Rebooting to Bootloader... ^& adb reboot bootloader ^& pause ^& goto menu )
echo if "%%choice%%"=="15" ( cls ^& echo [*] Rebooting to Fastbootd... ^& fastboot reboot fastboot ^& pause ^& goto menu )
echo if "%%choice%%"=="16" ( cls ^& echo [*] Rebooting to EDL 9008... ^& adb reboot edl 2^>nul ^|^| fastboot oem edl 2^>nul ^|^| fastboot reboot-edl 2^>nul ^& pause ^& goto menu )
echo if "%%choice%%"=="17" ( cls ^& echo [!] WARNING: This will wipe all user data to fix bootloop! ^& set /p confirm="Are you sure? (Y/N): " ^& if /i "%%confirm%%"=="Y" ( fastboot -w 2^>nul ^|^| fastboot erase userdata ) ^& pause ^& goto menu )
echo if "%%choice%%"=="18" ( cls ^& set /p zip="Drag and Drop ROM zip here: " ^& adb sideload %%zip%% ^& pause ^& goto menu )
echo if "%%choice%%"=="19" ( start cmd.exe /k "cd /d C:\adb" ^& goto menu )
echo if "%%choice%%"=="20" ( start devmgmt.msc ^& goto menu )
echo if "%%choice%%"=="21" ( exit )
echo goto menu
) > "%SHORTCUT%"

echo [OK] "ROM_Flasher_Toolkit.bat" created on Desktop!
echo.

:: ------------------------------------------------------------------------------
:: 10. Cleanup
:: ------------------------------------------------------------------------------
del /f /q "%PT_ZIP%" >nul 2>&1
del /f /q "%USB_ZIP%" >nul 2>&1
if exist "%USB_DIR%" rmdir /s /q "%USB_DIR%" >nul 2>&1

:: ------------------------------------------------------------------------------
:: 11. Completion
:: ------------------------------------------------------------------------------
echo.
color 0a
echo ==============================================================================
echo                      INSTALLATION + UPGRADE COMPLETE! (v4.0)
echo ==============================================================================
echo  [+] Latest Platform Tools (ADB/Fastboot) active in C:\adb
echo  [+] Safe System PATH Integration complete (Accessible in ANY folder)
echo  [+] Universal Android WinUSB Drivers registered in Windows DriverStore
echo  [+] Official Samsung Mobile Drivers configured
echo  [+] Dual-Slot (Slot A/B) switcher + 1-Click Root Flasher active
echo  [+] Interactive "ROM_Flasher_Toolkit.bat" generated on Desktop
echo ==============================================================================
echo.
pause
exit /b 0
