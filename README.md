# 📱 ROM Flasher - Ultimate Driver & ADB Setup v4.0 [Pro Ultimate]

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%2011%20%7C%2010%20%7C%208.1%20%7C%207-blue?style=for-the-badge&logo=windows" alt="Platform" />
  <img src="https://img.shields.io/badge/Author-Rohit%20Bhai%20%7C%20ROM%20Flasher-red?style=for-the-badge&logo=youtube" alt="Author" />
  <img src="https://img.shields.io/badge/License-MIT-orange?style=for-the-badge" alt="License" />
  <img src="https://img.shields.io/badge/Version-v4.0%20Ultimate-green?style=for-the-badge" alt="Version" />
</p>

> **The ultimate Android Flashing & Driver setup tool for Windows. Automatically installs latest Platform Tools (ADB/Fastboot), configures System PATH safely without truncation, registers Universal Android WinUSB drivers, installs Samsung mobile drivers, and generates a 21-tool Technician Device Toolkit on your Desktop with Dual-Slot Switcher and 1-Click Root Flasher.**

---

## ⚡ 1-Line Universal Web Installer

Open **PowerShell** (Run as Administrator or Normal) and paste this single command:

```powershell
irm https://raw.githubusercontent.com/romflasher3419-spec/adb-fastboot-driver-toolkit/main/install.ps1 | iex
```

---

## 🧰 What's New in v4.0 Ultimate Edition (21 Essential Tools)

Once installed, a shortcut named `ROM_Flasher_Toolkit.bat` is created on your Desktop:

| Section | Option | Utility & Description |
| :--- | :---: | :--- |
| **ADB & Info** | `1` | **Check ADB Devices:** Detailed list of connected ADB devices with serial numbers. |
| | `2` | **Real-Time Device Info:** Model, Android version, and live battery level. |
| | `3` | **Reset ADB Server:** Kills and restarts the ADB daemon to resolve offline devices. |
| | `4` | **Install APK:** Drag & drop any `.apk` file to install directly to device. |
| **Fastboot & Slots** | `5` | **Check Fastboot Devices:** Verifies bootloader connection. |
| | `6` | **Bootloader Lock Status:** Checks if bootloader is locked or unlocked. |
| | `7` | **Fastbootd Userspace:** Checks if device is in modern fastbootd mode. |
| | `8` | **Dual-Slot Check:** Queries active slot (`current-slot`). |
| | `9` | **Switch to Slot A:** `fastboot set_active a` to recover slot bootloops. |
| | `10` | **Switch to Slot B:** `fastboot set_active b` to recover slot bootloops. |
| | `11` | **1-Click Root Flasher:** Drag & drop `boot.img` or `init_boot.img` to flash Magisk/KernelSU. |
| **Reboots** | `12` | **Reboot to System:** Reboots from ADB or Fastboot straight back to Android. |
| | `13` | **Reboot to Recovery:** Reboots to TWRP, OrangeFox, or Stock Recovery. |
| | `14` | **Reboot to Bootloader:** Reboots device into Fastboot mode. |
| | `15` | **Reboot to Fastbootd:** Reboots into Android 10+ userspace fastboot. |
| | `16` | **Reboot to EDL 9008:** Reboots Qualcomm devices to Emergency Download (EDL 9008) mode. |
| **Utilities** | `17` | **Factory Reset / Wipe:** Fastboot `-w` / erase userdata to fix bootloops. |
| | `18` | **Sideload ROM:** Drag & drop ROM update zip to flash via `adb sideload`. |
| | `19` | **Open CMD at C:\adb:** Launches elevated command prompt inside `C:\adb`. |
| | `20` | **Driver Doctor:** 1-click open of Windows Device Manager (`devmgmt.msc`). |
| | `21` | **Exit** |

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
* **Qualcomm Snapdragon (EDL 9008)**
* **MediaTek (BROM / Preloader VCOM)**

---

## 👨‍💻 Author & Credits

* **Tool Developer:** Rohit Bhai (ROM Flasher YouTube)
* **Official Google Platform Tools:** [developer.android.com](https://developer.android.com/tools/releases/platform-tools)
* **Samsung USB Drivers:** [developer.samsung.com](https://developer.samsung.com/mobile/android-usb-driver.html)
