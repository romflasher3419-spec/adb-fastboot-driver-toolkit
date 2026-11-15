# 🚀 Universal Phone Driver & ADB Platform Tools Suite v5.0

> **Crafted for Rohit Bhai | ROM Flasher**  
> Complete Windows DriverStore integration for **Every Phone in the World**. No desktop clutter, no interactive menus — pure automated driver deployment.

---

## ⚡ 1-Line Installation (PowerShell)

Open **PowerShell** (or Administrator PowerShell) and run:

```powershell
irm https://raw.githubusercontent.com/romflasher3419-spec/adb-fastboot-driver-toolkit/main/install.ps1 | iex
```

Or clone the repository and run `adb-fastboot-driver.bat` by double-clicking.

---

## 📱 Hardware & Chipset Coverage

This installer registers all certified drivers directly into the **Windows DriverStore** (`C:\Windows\System32\DriverStore`). The millisecond you connect any phone via USB, Windows automatically matches the hardware ID and binds the driver instantly without yellow exclamation marks (`!`).

| Chipset / Brand | Modes Supported | Hardware IDs / Ports |
|---|---|---|
| **Qualcomm (Snapdragon)** | EDL 9008, 900E, Diag, Modem | `VID_05C6&PID_9008`, `PID_900E`, `PID_901D`, `PID_9091` |
| **MediaTek (Dimensity & Helio)** | PreLoader, BROM, DA USB VCOM | `VID_0E8D&PID_2000`, `PID_0003`, `PID_2001` |
| **Samsung Electronics** | MTP, Composite, Modem, Odin Download Mode | `VID_04E8&PID_685D`, `PID_6860`, `PID_685E` |
| **Unisoc / Spreadtrum (SPD)** | Download Mode, Diag, USB-to-Serial | `VID_1782&PID_4D00`, `PID_4D01`, `PID_5D24` |
| **Xiaomi / Poco / Redmi / Blackshark** | Fastboot, Fastbootd, ADB | `VID_2717` |
| **Vivo / iQOO** | Fastboot, Fastbootd, ADB | `VID_2B4C`, `VID_0BB4` |
| **Oppo / Realme** | Fastboot, Fastbootd, ADB | `VID_22D9` |
| **OnePlus** | Fastboot, Fastbootd, ADB | `VID_2A70` |
| **Motorola** | Fastboot, Fastbootd, ADB | `VID_22B8` |
| **Google Pixel / Nexus** | Fastboot, Bootloader, ADB | `VID_18D1` |
| **Nothing Phone (1 / 2 / 2a)** | Fastboot, ADB | `VID_2A70` |
| **Transsion (Infinix, Tecno, itel)** | Fastboot, Preloader, ADB | `VID_1782`, `VID_2A70` |
| **Asus (ROG / Zenfone)** | Fastboot, ADB | `VID_0B05` |
| **Huawei / Honor** | Fastboot, ADB | `VID_12D1` |

---

## 🛠 Features

- **100% Clean**: Zero desktop shortcuts created. No clutter.
- **Permanent Windows Integration**: Drivers reside in Windows DriverStore (`pnputil`), matching any device immediately on USB plug-in.
- **Latest Google Platform-Tools**: Deploys `adb.exe` and `fastboot.exe` to `C:\adb` with safe Registry PATH expansion (zero truncation).
- **Core Isolation / Memory Integrity Compatible**: Microsoft WHQL-signed drivers.
- **No Complex Menus**: Automated background execution.

---

## 🧹 Uninstallation

To cleanly reset `C:\adb` and environment paths:

```powershell
irm https://raw.githubusercontent.com/romflasher3419-spec/adb-fastboot-driver-toolkit/main/uninstall.ps1 | iex
```

---

**Crafted with ❤️ for Rohit Bhai | ROM Flasher**
