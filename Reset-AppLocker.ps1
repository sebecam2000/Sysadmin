<# 
 FULL LOCAL APPLOCKER RESET SCRIPT
 - Backs up local AppLocker / SRP registry keys
 - Backs up and removes C:\Windows\System32\AppLocker policy files
 - Tries to stop AppIDSvc / ClipSVC / AppReadiness (best effort)
 - Requires a REBOOT afterwards
#>

Write-Host "=== AppLocker full local reset ===" -ForegroundColor Cyan

# 1. Check admin
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "You must run this script as Administrator."
    return
}

# 2. Paths + backup folder
$applockerPath = Join-Path $env:windir "System32\AppLocker"
if (-not (Test-Path $applockerPath)) {
    Write-Warning "AppLocker folder not found at $applockerPath. Nothing to do."
    return
}

$backupRoot = "C:\AppLockerBackup"
$timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = Join-Path $backupRoot $timestamp

New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
Write-Host "Backup folder: $backupPath"

# 3. Backup relevant registry keys (if they exist)
$regKeys = @(
    'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppLocker',
    'HKLM\SOFTWARE\Policies\Microsoft\Windows\SrpV2',
    'HKLM\SOFTWARE\Policies\Microsoft\Windows\Safer\CodeIdentifiers'
)

foreach ($rk in $regKeys) {
    $rkPS = $rk -replace '^HKLM', 'HKLM:'
    if (Test-Path $rkPS) {
        $fileName = ($rk -replace '[\\/:*?"<>| ]','_') + ".reg"
        $dest = Join-Path $backupPath $fileName
        Write-Host "Exporting $rk -> $dest"
        & reg.exe export $rk $dest /y | Out-Null
    }
}

# 4. Try to stop related services (best effort, ignore failures)
$services = @('AppIDSvc','ClipSVC','AppReadiness')
foreach ($svc in $services) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($null -ne $s) {
        Write-Host "Stopping service $svc (if running)..." 
        try { Stop-Service $svc -Force -ErrorAction SilentlyContinue } catch {}
    }
}

# 5. Backup and remove AppLocker policy files
$files = @('Appx.AppLocker','Dll.AppLocker','Exe.AppLocker','Msi.AppLocker','Script.AppLocker','AppCache.dat')

foreach ($f in $files) {
    $src = Join-Path $applockerPath $f
    if (Test-Path $src) {
        $dst = Join-Path $backupPath $f
        Write-Host "Moving $src -> $dst"
        Move-Item -Path $src -Destination $dst -Force
    }
}

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Green
Write-Host "Local AppLocker policy files have been backed up and removed."
Write-Host "Backup location: $backupPath"
Write-Host ""
Write-Host "IMPORTANT: Reboot this machine now, then try your Add-AppxPackage commands again." -ForegroundColor Yellow
