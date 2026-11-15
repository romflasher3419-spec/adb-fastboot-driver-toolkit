# 📱 ROM Flasher - Ultimate Driver & ADB Setup v3.0 [Pro Edition]

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%2011%20%7C%2010%20%7C%208.1%20%7C%207-blue?style=for-the-badge&logo=windows" alt="Platform" />
  <img src="https://img.shields.io/badge/Author-Rohit%20Bhai%20%7C%20ROM%20Flasher-red?style=for-the-badge&logo=youtube" alt="Author" />
  <img src="https://img.shields.io/badge/License-MIT-orange?style=for-the-badge" alt="License" />
  <img src="https://img.shields.io/badge/Version-v3.0%20Pro-green?style=for-the-badge" alt="Version" />
</p>

> **The all-in-one Android Flashing & Driver setup tool for Windows. Automatically installs latest Platform Tools (ADB/Fastboot), configures System PATH safely without truncation, registers Universal Android WinUSB drivers, installs Samsung mobile drivers, and generates a 15-tool Technician Device Toolkit on your Desktop.**

---

## ⚡ 1-Line Universal Web Installer

Open **PowerShell** (Run as Administrator or Normal) and paste this single command:

```powershell
irm https://raw.githubusercontent.com/romflasher3419-spec/adb-fastboot-driver-toolkit/main/install.ps1 | iex
```

### 🎯 What This Command Does:
1. **Auto-Elevates to Administrator:** Seamless UAC trigger without manual right-clicking.
2. **Downloads Latest Google Platform Tools:** Installs the newest ADB and Fastboot binaries into `C:\adb`.
3. **Safe System PATH Integration:** Uses enterprise registry integration (`HKLM`) to safely add `C:\adb` to System PATH without the dangerous 1024-character truncation bug found in `setx`.
4. **Universal Android WinUSB Drivers:** Registers Google Android WinUSB drivers directly into Windows DriverStore for instant bootloader detection.
5. **Official Samsung Mobile Drivers:** Silently installs official Samsung drivers (Winget + direct fallback).
6. **Qualcomm & MediaTek Preparation:** Prepares driver protocols for EDL 9008 and MTK BROM flashing.
7. **Generates Desktop Toolkit:** Creates an interactive 15-option `ROM_Flasher_Toolkit.bat` on your Desktop.

---

## 🛠️ Offline / Standalone Batch Installation

If you prefer using an offline `.bat` file without running PowerShell commands:

1. Download [`adb-fastboot-driver.bat`](adb-fastboot-driver.bat) from this repository.
2. Double-click the file (it will automatically ask for Admin permissions).
3. Follow the on-screen instructions!

---

## 🧰 Desktop Toolkit v3.0 Menu Features

Once installed, a shortcut named `ROM_Flasher_Toolkit.bat` is created on your Desktop with 15 essential technician utilities:

| Section | Option | Command & Action |
| :--- | :---: | :--- |
| **ADB & Info** | `1` | **Check ADB Devices:** Lists connected ADB devices with detailed properties (`adb devices -l`). |
| | `2` | **Device Info:** Shows real-time device model name and battery charging status. |
| | `3` | **Reset ADB Server:** Kills and restarts the ADB daemon to resolve offline or undetected devices. |
| **Fastboot** | `4` | **Check Fastboot Devices:** Verifies fastboot/bootloader connection. |
| | `5` | **Bootloader Status:** Queries `fastboot oem device-info` to check if bootloader is locked or unlocked. |
| | `6` | **Fastbootd Userspace:** Checks if the device is currently in modern fastbootd mode (Android 10+ dynamic partitions). |
| **Reboots** | `7` | **Reboot to System:** Reboots from ADB or Fastboot straight back to Android OS. |
| | `8` | **Reboot to Recovery:** Reboots device to TWRP, OrangeFox, or Stock Recovery. |
| | `9` | **Reboot to Bootloader:** Reboots device into Fastboot/Bootloader mode. |
| | `10` | **Reboot to Fastbootd:** Reboots into Android 10+ userspace fastboot (`fastboot reboot fastboot`). |
| | `11` | **Reboot to EDL 9008:** Reboots Qualcomm devices to Emergency Download (EDL 9008) mode for unbricking. |
| **Flashing** | `12` | **Sideload ROM:** Allows you to drag & drop any `.zip` ROM update to flash via ADB sideload. |
| | `13` | **Open CMD at C:\adb:** Launches an elevated command prompt inside `C:\adb`. |
| | `14` | **Driver Doctor:** 1-click open of Windows Device Manager (`devmgmt.msc`) to inspect driver status. |
| | `15` | **Exit** |

---

## 📱 Supported Device Brands

* **Xiaomi, Redmi, POCO**
* **Samsung Galaxy**
* **Vivo & iQOO**
* **Oppo & Realme**
* **OnePlus**
* **Google Pixel**
* **Motorola**
* **Nothing Phone**
* **Infinix, Tecno, itel (Transsion MTK/Unisoc)**
* **Asus ROG / Zenfone**
* **Qualcomm Snapdragon (EDL 9008)**
* **MediaTek (BROM / Preloader VCOM)**

---

## 🗑️ How to Uninstall

To remove `C:\adb` and restore your original System PATH:
1. Run [`uninstall.ps1`](uninstall.ps1) with PowerShell as Administrator.

---

## 👨‍💻 Author & Credits

* **Tool Developer:** Rohit Bhai (ROM Flasher YouTube)
* **Official Google Platform Tools:** [developer.android.com](https://developer.android.com/tools/releases/platform-tools)
* **Samsung USB Drivers:** [developer.samsung.com](https://developer.samsung.com/mobile/android-usb-driver.html)
