<p align="center">
  <img src="screenshots/banner.png" alt="HORUSx" width="700"/>
</p>

<h1 align="center">HORUSx</h1>

<p align="center">
  <em>Control any Android phone from your Windows PC — over Wi-Fi, no cables, no root.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Windows-blue?style=flat-square" alt="Windows">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/powered%20by-scrcpy-orange?style=flat-square" alt="scrcpy">
  <img src="https://img.shields.io/badge/version-1.0.0-blueviolet?style=flat-square" alt="Version">
</p>

---

**Built by [mufasa119](https://github.com/mufasa119)**  
**Powered by [scrcpy](https://github.com/Genymobile/scrcpy) + [ADB](https://developer.android.com/tools/adb)**

---

## ✨ Features

- 🚀 **Auto-installs dependencies** — if ADB or scrcpy are missing, HORUSx installs them via Winget on the first run
- 📡 **Wireless** — connects over Wi-Fi using Android's built-in Wireless Debugging
- ⚡ **Low latency** — 30 FPS at ~50–100 ms, powered by scrcpy
- 🖱️ **Full remote control** — clicks become taps, your keyboard types on the phone
- 💾 **Remembers your setup** — optional local config saves your connection for one-key reconnects
- 🎨 **Stylish CLI** — colored banner because tools should look good too
- 🔒 **No data collection** — nothing is ever sent anywhere. Everything runs on your PC
- 📦 **Single `.exe`** — no Python, no Node, no manual setup for the user

---

## 📥 Install — Two Options

### 🅰️ Option A — Download the ready-made `.exe` (recommended)

**No setup required.**

1. Go to the [**Releases**](../../releases) page
2. Download the latest **`HorusX.exe`**
3. Save it anywhere on your PC (e.g. `C:\HorusX\HorusX.exe`)
4. **Double-click it** to run

On the first launch, HORUSx will:
- Check for ADB and scrcpy
- Offer to install them via Winget if missing
- Ask you to restart PowerShell once (Windows requirement)
- Then continue normally

> ⚠️ **Windows SmartScreen warning?**  
> Click **"More info" → "Run anyway"**. This appears because the `.exe` isn't code-signed — it's safe.

---

### 🅱️ Option B — Run from source (advanced)

If you prefer to run the PowerShell script directly:

1. **Install the prerequisites manually:**

   ```powershell
   choco install adb scrcpy -y
   ```
   *(Or install [ADB](https://developer.android.com/tools/releases/platform-tools) and [scrcpy](https://github.com/Genymobile/scrcpy) manually and add them to your PATH)*

2. **Download** `horusX.ps1` from this repo

3. **Allow script execution and run:**

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\horusX.ps1
   ```

---

## 🖥️ Requirements

- **Windows 10 (1809+) or Windows 11**
- **Android 11+** on the phone (for Wireless Debugging)
- **Internet connection** (for the one-time auto-install of ADB + scrcpy)

**No manual setup needed** — HORUSx installs ADB and scrcpy automatically on the first run.

---

## 🚀 Quick Start

### 1. Enable Wireless Debugging on your phone

1. Settings → **About phone** → tap **Build number** 7 times
2. Settings → **Developer options** → enable **Wireless debugging**
3. *(Samsung)* Settings → **Security and privacy** → disable **Auto Blocker**

### 2. Get the pairing info

1. Tap **Wireless debugging** → **Pair device with pairing code**
2. Note the **IP:pairing-port** and **6-digit code**
3. **Keep the dialog open** — codes expire in ~2 minutes

### 3. Run HORUSx

1. **Double-click `HorusX.exe`**
2. On the first run, approve the auto-install of ADB and scrcpy
3. **Restart PowerShell** once (Windows needs this for PATH updates)
4. Double-click `HorusX.exe` again → enter your phone's pairing info
5. **scrcpy opens** — you're now controlling your phone 🎉

---

## 🎮 Controls (in scrcpy)

| Action | Shortcut |
|---|---|
| Tap | **Left-click** |
| Swipe | **Click and drag** |
| Scroll | **Mouse wheel** |
| Back | **Right-click** |
| Home | `Ctrl + H` |
| Type text | Just **start typing** |
| Phone screen off (keeps mirroring) | `Ctrl + Shift + O` |
| Full screen | `Ctrl + F` |

---

## 🛠️ Building from Source

If you want to modify the script or build your own version:

```powershell
# 1. Install ps2exe (compiles .ps1 to .exe)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Install-Module ps2exe -Scope CurrentUser -Force

# 2. Compile
cd C:\path\to\HorusX
Import-Module ps2exe
Invoke-PS2EXE .\horusX.ps1 .\HorusX.exe -iconFile .\horusX.ico
```

---

## 🐛 Troubleshooting

| Issue | Fix |
|---|---|
| `adb not recognized` | Run `winget install Google.PlatformTools` and restart PowerShell |
| `scrcpy not recognized` | Run `winget install Genymobile.scrcpy` and restart PowerShell |
| Pairing fails | Reopen the pairing dialog — codes expire quickly |
| Connection times out | Phone and PC must be on the same Wi-Fi |
| Old icon shows after update | Run `ie4uinit.exe -show` to refresh Windows icon cache |
| EXE blocked by SmartScreen | Click **More info → Run anyway** |
| Winget not available | Update Windows — Winget ships with Windows 10 1809+ |

---

## 🔒 Privacy & Security

HORUSx runs **entirely on your PC**. It does **not** send any data anywhere.

- ✅ No accounts, no telemetry, no cloud
- ✅ The optional saved config (`horus_config.json`) is a plain local file with only: IP, port, last-used time
- ✅ All traffic stays on your own Wi-Fi network

**Important:**
- Only use on **your own devices**, on **trusted networks**
- Turn off Wireless Debugging on the phone when not using HORUSx
- **Never install this on someone else's phone without their explicit knowledge and consent**

---

## 📸 Screenshots

| Banner | Live Session |
|---|---|
| ![Banner](screenshots/banner.png) | ![scrcpy](screenshots/session.png) |

> Add `screenshots/session.png` — a real screenshot of scrcpy running with your phone screen mirrored.

---

## 🗺️ Roadmap

- [ ] Dark/light banner themes
- [ ] Multi-device profile management
- [ ] Optional encrypted config storage
- [ ] macOS / Linux support

---

## 📄 License

**MIT License** — free to use, modify, and distribute. See [LICENSE](LICENSE).

---

## 🙌 Credits

- Built by **[mufasa119](https://github.com/mufasa119)**
- Powered by **[scrcpy](https://github.com/Genymobile/scrcpy)** by Genymobile
- Uses **[ADB](https://developer.android.com/tools/adb)** from Android Platform Tools

---

⭐ **If HORUSx is useful to you, please star the repo!**  
🐛 **Found a bug? Open an issue.**  
💡 **Have an idea? Start a discussion.**
