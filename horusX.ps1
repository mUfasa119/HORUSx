# ==================================================
#  HORUSx — Remote Control Tool
#  by mufasa119
# ==================================================

Clear-Host

# Ensure terminal is wide enough for the banner
try {
    [Console]::SetWindowSize(110, 55)
    [Console]::BufferWidth = 110
} catch {
    try { $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(110, 55) } catch {}
}

# ─── Config path ───
# Works whether running as .ps1 or compiled .exe
$scriptDir = ""
if (-not [string]::IsNullOrEmpty($PSScriptRoot)) {
    $scriptDir = $PSScriptRoot
} elseif ($MyInvocation.MyCommand.Path) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    $scriptDir = $PWD.Path
}
$ConfigFile = Join-Path $scriptDir "horus_config.json"

# ═══════════════════════════════════════════════════════════════
#                        HORUSx BANNER
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  ██╗  ██╗ ██████╗ ██████╗ ██╗   ██╗███████╗██╗  ██╗" -ForegroundColor Red
Write-Host "  ██║  ██║██╔═══██╗██╔══██╗██║   ██║██╔════╝╚██╗██╔╝" -ForegroundColor Red
Write-Host "  ███████║██║   ██║██████╔╝██║   ██║███████╗ ╚███╔╝ " -ForegroundColor Red
Write-Host "  ██╔══██║██║   ██║██╔══██╗██║   ██║╚════██║ ██╔██╗ " -ForegroundColor Red
Write-Host "  ██║  ██║╚██████╔╝██║  ██║╚██████╔╝███████║██╔╝ ██╗" -ForegroundColor Red
Write-Host "  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝" -ForegroundColor Red
Write-Host ""
Write-Host "                    by mufasa119" -ForegroundColor Magenta
Write-Host ""
Write-Host "  ══════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""

# ═══════════════════════════════════════════════════════════════
#                    STEP 1: PREREQUISITES
# ═══════════════════════════════════════════════════════════════
Write-Host "  STEP 1/4 — Checking required tools (adb & scrcpy)" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [*] Checking prerequisites..." -ForegroundColor Yellow

$needAdb    = -not (Get-Command adb -ErrorAction SilentlyContinue)
$needScrcpy = -not (Get-Command scrcpy -ErrorAction SilentlyContinue)

if ($needAdb -or $needScrcpy) {
    Write-Host ""
    Write-Host "  [!] Missing tools detected:" -ForegroundColor Yellow
    if ($needAdb)    { Write-Host "      - adb" -ForegroundColor Red }
    if ($needScrcpy) { Write-Host "      - scrcpy" -ForegroundColor Red }
    Write-Host ""
    Write-Host "  These tools let HORUSx talk to your phone and mirror its screen." -ForegroundColor Gray
    Write-Host "  They will be installed automatically using Windows' built-in Winget." -ForegroundColor Gray
    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "  │  TYPE:  y   and press Enter to install               │" -ForegroundColor Cyan
    Write-Host "  │  TYPE:  n   to cancel and install manually           │" -ForegroundColor Cyan
    Write-Host "  └──────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    Write-Host ""

    $installChoice = Read-Host "  Install them automatically now? [Y/n]"
    if ($installChoice -eq "" -or $installChoice -match "^[Yy]") {

        $hasWinget = Get-Command winget -ErrorAction SilentlyContinue

        if (-not $hasWinget) {
            Write-Host ""
            Write-Host "  [X] Winget is not available on this system." -ForegroundColor Red
            Write-Host "      Winget is the built-in Windows package manager (Windows 10 1809+)." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  Options:" -ForegroundColor Yellow
            Write-Host "    1. Update Windows to get winget" -ForegroundColor Gray
            Write-Host "    2. Install manually:" -ForegroundColor Gray
            Write-Host "       - ADB:    https://developer.android.com/tools/releases/platform-tools" -ForegroundColor Gray
            Write-Host "       - scrcpy: https://github.com/Genymobile/scrcpy/releases" -ForegroundColor Gray
            Write-Host ""
            Read-Host "  Press Enter to exit"
            exit 1
        }

        Write-Host ""
        Write-Host "  [*] Using winget to install tools... (this may take 1-2 minutes)" -ForegroundColor Cyan
        Write-Host ""

        if ($needScrcpy) {
            Write-Host "  [*] Installing scrcpy (includes ADB dependencies)..." -ForegroundColor Cyan
            winget install --id Genymobile.scrcpy --exact --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [+] scrcpy installed." -ForegroundColor Green
            } elseif ($LASTEXITCODE -eq -1978335189) {
                Write-Host "  [i] scrcpy is already installed — skipping." -ForegroundColor Cyan
            } else {
                Write-Host "  [!] scrcpy install returned code $LASTEXITCODE." -ForegroundColor Yellow
            }
        }

        if ($needAdb) {
            Write-Host ""
            Write-Host "  [*] Installing ADB platform tools..." -ForegroundColor Cyan
            winget install --id Google.PlatformTools --exact --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [+] ADB installed." -ForegroundColor Green
            } elseif ($LASTEXITCODE -eq -1978335189) {
                Write-Host "  [i] ADB is already installed — skipping." -ForegroundColor Cyan
            } else {
                Write-Host "  [!] ADB install returned code $LASTEXITCODE." -ForegroundColor Yellow
                Write-Host "      Try manually: https://developer.android.com/tools/releases/platform-tools" -ForegroundColor Gray
            }
        }

        Write-Host ""
        Write-Host "  ══════════════════════════════════════════════════════════" -ForegroundColor DarkGray
        Write-Host "  [!] IMPORTANT — RESTART REQUIRED" -ForegroundColor Yellow
        Write-Host "  ══════════════════════════════════════════════════════════" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Windows needs a fresh terminal to see the new tools." -ForegroundColor Gray
        Write-Host ""
        Write-Host "  NEXT STEPS:" -ForegroundColor Cyan
        Write-Host "    1. Press Enter below to close this window" -ForegroundColor Gray
        Write-Host "    2. Open a NEW PowerShell window" -ForegroundColor Gray
        Write-Host "    3. Run horusX.exe again" -ForegroundColor Gray
        Write-Host ""
        Read-Host "  Press Enter to exit"
        exit 0
    } else {
        Write-Host ""
        Write-Host "  [*] Skipped. Install manually, then run this script again." -ForegroundColor Gray
        Read-Host "  Press Enter to exit"
        exit 1
    }
}

Write-Host "  [+] Prerequisites OK — adb and scrcpy are ready." -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════════
#                    STEP 2: SAVED CONNECTION
# ═══════════════════════════════════════════════════════════════
Write-Host "  STEP 2/4 — Saved connection info" -ForegroundColor Yellow
Write-Host ""

$savedConfig   = $null
$lastIp        = ""
$lastPort      = ""
$useSavedInfo  = $false

if (Test-Path $ConfigFile) {
    try {
        $savedConfig = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        if ($savedConfig.LastIp)   { $lastIp   = $savedConfig.LastIp }
        if ($savedConfig.LastPort) { $lastPort = $savedConfig.LastPort }

        Write-Host "  Found a previously saved connection:" -ForegroundColor Cyan
        Write-Host "  ┌────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
        Write-Host "  │  Phone IP : $lastIp" -ForegroundColor Gray
        Write-Host "  │  Port     : $lastPort" -ForegroundColor Gray
        if ($savedConfig.LastUsed) {
            Write-Host "  │  Last used: $($savedConfig.LastUsed)" -ForegroundColor Gray
        }
        Write-Host "  └────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  ┌──────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
        Write-Host "  │  TYPE:  y  or just press Enter  → use saved info     │" -ForegroundColor Cyan
        Write-Host "  │  TYPE:  n                        → enter new info    │" -ForegroundColor Cyan
        Write-Host "  └──────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
        Write-Host ""

        $useSaved = Read-Host "  Use saved connection info? [Y/n]"
        if ($useSaved -eq "" -or $useSaved -match "^[Yy]") {
            Write-Host "  [+] Using saved connection." -ForegroundColor Green
            $ip = $lastIp
            $connPort = $lastPort
            $useSavedInfo = $true
        } else {
            Write-Host "  [*] OK — you'll enter new connection info next." -ForegroundColor Yellow
            $useSavedInfo = $false
        }
        Write-Host ""
    } catch {
        Write-Host "  [!] Saved config was corrupted — starting fresh." -ForegroundColor Yellow
        $savedConfig  = $null
        $useSavedInfo = $false
    }
} else {
    Write-Host "  No saved connection found (this is normal on first run)." -ForegroundColor Gray
    Write-Host ""
    $useSavedInfo = $false
}

# ═══════════════════════════════════════════════════════════════
#                    STEP 3: CONNECTION INFO
# ═══════════════════════════════════════════════════════════════
if (-not $useSavedInfo) {

    Write-Host "  STEP 3/4 — Get connection info from your phone" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ┌────────────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "  │  ON YOUR ANDROID PHONE:                                    │" -ForegroundColor Cyan
    Write-Host "  │                                                            │" -ForegroundColor Cyan
    Write-Host "  │  1. Go to: Settings > Developer options                    │" -ForegroundColor Gray
    Write-Host "  │  2. Enable 'Wireless debugging'                            │" -ForegroundColor Gray
    Write-Host "  │  3. Tap 'Wireless debugging' > 'Pair device with code'     │" -ForegroundColor Gray
    Write-Host "  │  4. Keep that dialog OPEN — it shows 2 things you need:    │" -ForegroundColor Gray
    Write-Host "  │       • IP address & port   (e.g., 192.168.1.10:43210)     │" -ForegroundColor Gray
    Write-Host "  │       • 6-digit pairing code                               │" -ForegroundColor Gray
    Write-Host "  └────────────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    Write-Host ""

    Write-Host "  [INPUT 1 of 3]" -ForegroundColor Cyan
    Write-Host "  Type the IP:pairing-port exactly as shown on the phone." -ForegroundColor Gray
    Write-Host "  Example:  192.168.1.10:43210" -ForegroundColor DarkGray
    $pairAddr = Read-Host "  > "
    Write-Host ""

    Write-Host "  [INPUT 2 of 3]" -ForegroundColor Cyan
    Write-Host "  Type the 6-digit pairing code shown on the phone." -ForegroundColor Gray
    Write-Host "  Example:  483921" -ForegroundColor DarkGray
    $pairCode = Read-Host "  > "
    Write-Host ""

    Write-Host "  [INPUT 3 of 3]" -ForegroundColor Cyan
    Write-Host "  Go BACK to the main 'Wireless debugging' screen (close the" -ForegroundColor Gray
    Write-Host "  pairing dialog). It shows a DIFFERENT port at the top, like:" -ForegroundColor Gray
    Write-Host "      192.168.1.10:5555" -ForegroundColor DarkGray
    Write-Host "  Type ONLY the port number (e.g., 5555)." -ForegroundColor Gray
    if ($lastPort) {
        Write-Host "  (Press Enter to reuse last saved port: $lastPort)" -ForegroundColor DarkGray
        $portInput = Read-Host "  > "
        $connPort = if ([string]::IsNullOrWhiteSpace($portInput)) { $lastPort } else { $portInput }
    } else {
        $connPort = Read-Host "  > "
    }
    Write-Host ""

    # Extract IP from pairing address
    $ip = ($pairAddr -split ':')[0]

    # ─── Pair ───
    Write-Host "  [*] Pairing with $pairAddr ..." -ForegroundColor Cyan
    $pairOut = adb pair $pairAddr $pairCode 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "  [X] Pairing failed." -ForegroundColor Red
        Write-Host "  $pairOut" -ForegroundColor Red
        Write-Host ""
        Write-Host "  ┌── Troubleshooting ───────────────────────────────────┐" -ForegroundColor Yellow
        Write-Host "  │  • Keep the pairing dialog OPEN on the phone         │" -ForegroundColor Gray
        Write-Host "  │  • The code expires in ~2 minutes                    │" -ForegroundColor Gray
        Write-Host "  │  • Pairing port ≠ connection port                    │" -ForegroundColor Gray
        Write-Host "  │  • Phone and PC must be on the same Wi-Fi            │" -ForegroundColor Gray
        Write-Host "  └──────────────────────────────────────────────────────┘" -ForegroundColor Yellow
        Read-Host "`n  Press Enter to exit"
        exit 1
    }
    Write-Host "  [+] Paired successfully." -ForegroundColor Green
    Write-Host ""
}

# ═══════════════════════════════════════════════════════════════
#                    STEP 4: CONNECT + LAUNCH
# ═══════════════════════════════════════════════════════════════
Write-Host "  STEP 4/4 — Connecting to your phone" -ForegroundColor Yellow
Write-Host ""

$target = "$ip`:$connPort"
Write-Host "  [*] Connecting to $target ..." -ForegroundColor Cyan
adb connect $target | Out-Null

$adbOut = adb devices
if ($adbOut -match [regex]::Escape($target) + "\s+device") {
    Write-Host "  [+] Connected." -ForegroundColor Green
} else {
    Write-Host "  [X] Could not connect to $target" -ForegroundColor Red
    Write-Host ""
    Write-Host "  ┌── Troubleshooting ───────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "  │  • Phone and PC must be on the same Wi-Fi            │" -ForegroundColor Gray
    Write-Host "  │  • Re-enable Wireless Debugging on the phone         │" -ForegroundColor Gray
    Write-Host "  │  • The connection port may have changed              │" -ForegroundColor Gray
    Write-Host "  │  • Try again — this sometimes works on 2nd attempt   │" -ForegroundColor Gray
    Write-Host "  └──────────────────────────────────────────────────────┘" -ForegroundColor Yellow
    Read-Host "`n  Press Enter to exit"
    exit 1
}

# ─── Save connection info (optional) ───
Write-Host ""
if (-not $useSavedInfo) {
    Write-Host "  ┌──────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "  │  TYPE:  y   → save this connection for next time     │" -ForegroundColor Cyan
    Write-Host "  │  TYPE:  n   → don't save (you'll type it next time)  │" -ForegroundColor Cyan
    Write-Host "  └──────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    $saveChoice = Read-Host "  Save this connection info for next time? [y/N]"
    if ($saveChoice -match "^[Yy]") {
        try {
            $config = @{
                LastIp   = $ip
                LastPort = $connPort
                LastUsed = (Get-Date).ToString("yyyy-MM-dd HH:mm")
            } | ConvertTo-Json
            Set-Content -Path $ConfigFile -Value $config -Encoding UTF8
            Write-Host "  [+] Saved to $ConfigFile" -ForegroundColor Green
        } catch {
            Write-Host "  [!] Could not save: $_" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [*] Not saved. You'll be asked again next time." -ForegroundColor Gray
    }
} else {
    try {
        $config = @{
            LastIp   = $ip
            LastPort = $connPort
            LastUsed = (Get-Date).ToString("yyyy-MM-dd HH:mm")
        } | ConvertTo-Json
        Set-Content -Path $ConfigFile -Value $config -Encoding UTF8
    } catch { }
}

# ═══════════════════════════════════════════════════════════════
#                    LAUNCH SCRCPY (with auto-disconnect)
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  ══════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "  [*] Launching scrcpy — low-delay mode..." -ForegroundColor Cyan
Write-Host ""
Write-Host "  CONTROLS:" -ForegroundColor Yellow
Write-Host "    Left-click      → tap" -ForegroundColor Gray
Write-Host "    Right-click     → back" -ForegroundColor Gray
Write-Host "    Ctrl + H        → home" -ForegroundColor Gray
Write-Host "    Mouse wheel     → scroll" -ForegroundColor Gray
Write-Host "    Just type       → types on the phone" -ForegroundColor Gray
Write-Host "    Ctrl + Shift+O  → phone screen off (mirroring continues)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Close the scrcpy window to end the session." -ForegroundColor Gray
Write-Host ""

try {
    Start-Process scrcpy -ArgumentList @(
        "-s", $target,
        "--max-size", "1024",
        "--video-bit-rate", "4M",
        "--max-fps", "30",
        "--no-audio"
    ) -Wait
}
finally {
    Write-Host ""
    Write-Host "  [*] Disconnecting from $target ..." -ForegroundColor Cyan
    adb disconnect $target 2>&1 | Out-Null
    Write-Host "  [+] Disconnected." -ForegroundColor Green

    Write-Host ""
    Write-Host "  [+] Session ended. Thanks for using HORUSx!" -ForegroundColor Green
    Read-Host "  Press Enter to exit"
}