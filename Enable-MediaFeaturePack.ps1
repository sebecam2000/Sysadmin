Write-Host "=== 1) Sauvegarde de la config WSUS ==="
$backupPath = "$env:ProgramData\WSUS_WindowsUpdate_Backup.reg"
reg export "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "$backupPath" /y | Out-Null
Write-Host "Config WSUS sauvegardée dans $backupPath"

Write-Host "=== 2) Désactivation temporaire de WSUS (bypass) ==="
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v UseWUServer /t REG_DWORD /d 0 /f | Out-Null
net stop wuauserv | Out-Null
net start wuauserv | Out-Null

Write-Host "=== 3) Installation des fonctionnalités Media ==="

$capabilities = @(
    "Media.MediaFeaturePack~~~~0.0.1.0",
    "Media.WindowsMediaPlayer~~~~0.0.12.0"
)

foreach ($cap in $capabilities) {
    Write-Host "Installation de la capacité : $cap"
    DISM /Online /Add-Capability /CapabilityName:$cap
}

Write-Host "=== 4) Restauration de la config WSUS ==="
reg import "$backupPath" | Out-Null
net stop wuauserv | Out-Null
net start wuauserv | Out-Null

Write-Host "=== Terminé. Redémarre la machine puis teste la caméra et l'iPhone. ==="
