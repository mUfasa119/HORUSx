# ==================================================
#  HORUSx — Remote Control Tool
#  by mufasa119
# ==================================================

Clear-Host

# Ensure terminal is wide enough for the banner
try {
    [Console]::SetWindowSize(100, 50)
    [Console]::BufferWidth = 100
} catch {
    try { $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(100, 50) } catch {}
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
#                    PREREQUISITES CHECK + AUTO-INSTALL
# ═══════════════════════════════════════════════════════════════
Write-Host "  [*] Checking prerequisites..." -ForegroundColor Yellow

$needAdb    = -not (Get-Command adb -ErrorAction SilentlyContinue)
$needScrcpy = -not (Get-Command scrcpy -ErrorAction SilentlyContinue)

if ($needAdb -or $needScrcpy) {
    Write-Host ""
    Write-Host "  [!] Missing tools detected:" -ForegroundColor Yellow
    if ($needAdb)    { Write-Host "      - adb" -ForegroundColor Red }
    if ($needScrcpy) { Write-Host "      - scrcpy" -ForegroundColor Red }
    Write-Host ""

    $installChoice = Read-Host "  Install them automatically now? [Y/n]"
    if ($installChoice -eq "" -or $installChoice -match "^[Yy]") {

        # Check if winget is available
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

        # Confirm winget
        Write-Host ""
        Write-Host "  [*] Using winget to install tools..." -ForegroundColor Cyan
        Write-Host ""

        if ($needScrcpy) {
            Write-Host "  [*] Installing scrcpy (includes ADB dependencies)..." -ForegroundColor Cyan
            winget install --id Genymobile.scrcpy --exact --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  [!] scrcpy install may have failed (exit code $LASTEXITCODE). Continuing..." -ForegroundColor Yellow
            } else {
                Write-Host "  [+] scrcpy installed." -ForegroundColor Green
            }
        }

        if ($needAdb) {
            Write-Host ""
            Write-Host "  [*] Installing ADB platform tools..." -ForegroundColor Cyan
            winget install --id Google.PlatformTools --exact --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  [!] ADB install may have failed (exit code $LASTEXITCODE)." -ForegroundColor Yellow
                Write-Host "      Try installing manually: https://developer.android.com/tools/releases/platform-tools" -ForegroundColor Gray
            } else {
                Write-Host "  [+] ADB installed." -ForegroundColor Green
            }
        }

        Write-Host ""
        Write-Host "  [!] IMPORTANT: Restart PowerShell for the new tools to be on PATH." -ForegroundColor Yellow
        Write-Host "      After restart, run horusX.ps1 again." -ForegroundColor Gray
        Write-Host ""
        Read-Host "  Press Enter to exit"
        exit 0
    } else {
        Write-Host "  [*] Skipped. Install manually then run again." -ForegroundColor Gray
        Read-Host "  Press Enter to exit"
        exit 1
    }
}

Write-Host "  [+] Prerequisites OK." -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════════
#                    LOAD SAVED INFO (OPTIONAL)
# ═══════════════════════════════════════════════════════════════
$savedConfig   = $null
$lastIp        = ""
$lastPort      = ""
$useSavedInfo  = $false

if (Test-Path $ConfigFile) {
    try {
        $savedConfig = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        if ($savedConfig.LastIp)   { $lastIp   = $savedConfig.LastIp }
        if ($savedConfig.LastPort) { $lastPort = $savedConfig.LastPort }

        Write-Host "  ┌─── Saved Connection Found ─────────────────────┐" -ForegroundColor DarkCyan
        Write-Host "  │  Phone IP : $lastIp" -ForegroundColor Gray
        Write-Host "  │  Port     : $lastPort" -ForegroundColor Gray
        if ($savedConfig.LastUsed) {
            Write-Host "  │  Last used: $($savedConfig.LastUsed)" -ForegroundColor Gray
        }
        Write-Host "  └────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
        Write-Host ""

        $useSaved = Read-Host "  Use saved connection info? [Y/n]"
        if ($useSaved -eq "" -or $useSaved -match "^[Yy]") {
            Write-Host "  [+] Using saved info." -ForegroundColor Green
            $ip = $lastIp
            $connPort = $lastPort
            $useSavedInfo = $true
        } else {
            Write-Host "  [*] Enter new connection info." -ForegroundColor Yellow
            $useSavedInfo = $false
        }
        Write-Host ""
    } catch {
        Write-Host "  [!] Saved config is corrupted - starting fresh." -ForegroundColor Yellow
        $savedConfig  = $null
        $useSavedInfo = $false
    }
} else {
    $useSavedInfo = $false
}

# ═══════════════════════════════════════════════════════════════
#                    CONNECTION INFO
# ═══════════════════════════════════════════════════════════════
if (-not $useSavedInfo) {
    Write-Host "  --- Connection Details ---" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Pairing is always required (codes expire after one use)." -ForegroundColor Gray
    Write-Host ""

    $pairAddr = Read-Host "  Phone IP + pairing port (e.g. 192.168.1.10:43210)"
    $pairCode = Read-Host "  6-digit pairing code"

    if ($lastPort) {
        $portInput = Read-Host "  Connection port [$lastPort]"
        $connPort = if ([string]::IsNullOrWhiteSpace($portInput)) { $lastPort } else { $portInput }
    } else {
        $connPort = Read-Host "  Connection port (main Wireless Debugging screen)"
    }

    $ip = ($pairAddr -split ':')[0]

    Write-Host ""
    Write-Host "  [*] Pairing with $pairAddr..." -ForegroundColor Cyan
    $pairOut = adb pair $pairAddr $pairCode 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [X] Pairing failed:" -ForegroundColor Red
        Write-Host "  $pairOut" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Tips:" -ForegroundColor Yellow
        Write-Host "    - Keep the pairing dialog open on the phone" -ForegroundColor Gray
        Write-Host "    - Codes expire - reopen the dialog if it's been a while" -ForegroundColor Gray
        Write-Host "    - The pairing port and connection port are different" -ForegroundColor Gray
        Read-Host "`n  Press Enter to exit"
        exit 1
    }
    Write-Host "  [+] Paired successfully." -ForegroundColor Green
}

# ═══════════════════════════════════════════════════════════════
#                    CONNECT
# ═══════════════════════════════════════════════════════════════
$target = "$ip`:$connPort"
Write-Host "  [*] Connecting to $target..." -ForegroundColor Cyan
adb connect $target | Out-Null

$adbOut = adb devices
if ($adbOut -match [regex]::Escape($target) + "\s+device") {
    Write-Host "  [+] Connected." -ForegroundColor Green
} else {
    Write-Host "  [X] Could not connect to $target" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Tips:" -ForegroundColor Yellow
    Write-Host "    - Ensure the phone is on the same Wi-Fi network" -ForegroundColor Gray
    Write-Host "    - Re-enable Wireless Debugging on the phone" -ForegroundColor Gray
    Write-Host "    - The connection port may have changed" -ForegroundColor Gray
    Read-Host "`n  Press Enter to exit"
    exit 1
}

# ═══════════════════════════════════════════════════════════════
#                    SAVE INFO (OPTIONAL)
# ═══════════════════════════════════════════════════════════════
Write-Host ""
if (-not $useSavedInfo) {
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
        Write-Host "  [*] Not saved. You'll be asked next time." -ForegroundColor Gray
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
#                    LAUNCH SCRCPY
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  [*] Launching scrcpy (low-delay mode)..." -ForegroundColor Cyan
Write-Host "      Close the scrcpy window to end the session." -ForegroundColor Gray
Write-Host ""

Start-Process scrcpy -ArgumentList @(
    "-s", $target,
    "--max-size", "1024",
    "--video-bit-rate", "4M",
    "--max-fps", "30",
    "--no-audio"
) -Wait

Write-Host ""
Write-Host "  [+] Session ended." -ForegroundColor Green
Read-Host "  Press Enter to exit"