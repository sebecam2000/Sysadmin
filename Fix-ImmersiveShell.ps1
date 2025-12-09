# Fix-ImmersiveShell.ps1
# Fixes the menubar/taskbar disappearance after Windows Updates
# Run in *user* context (not SYSTEM)
Set-ExecutionPolicy Unrestricted

$guid = '{C4A1D1E2-1234-4567-ABCD-00000000TEMP}'

$base = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer\CodeIdentifiers\0\Paths\$guid"

New-Item -Path $base -Force | Out-Null
New-ItemProperty -Path $base -Name "SaferFlags" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $base -Name "ItemData" -Value "C:\Temp\*" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $base -Name "Description" -Value "Allow admin scripts in C:\Temp" -PropertyType String -Force | Out-Null

gpupdate /force


Get-Service AppIDSvc
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" -Name "AllowAllTrustedApps" -Type DWord -Value 1
reg add "HKLM\Software\Policies\Microsoft\Windows\UnlockWindows" /v AllowDevelopmentWithoutDevLicense /t REG_DWORD /d 1 /f
Add-AppxPackage -Register -Path C:\Windows\SystemApps\Microsoft.Windows.Client.CBS_*\AppxManifest.xml -DisableDevelopmentMode

$ErrorActionPreference = 'Stop'

$packages = @(
    'C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\appxmanifest.xml',
    'C:\Windows\SystemApps\Microsoft.UI.Xaml.CBS_8wekyb3d8bbwe\appxmanifest.xml',
    'C:\Windows\SystemApps\MicrosoftWindows.Client.Core_cw5n1h2txyewy\appxmanifest.xml'
)

foreach ($pkg in $packages) {
    if (Test-Path $pkg) {
        Write-Host "Registering: $pkg"
        Add-AppxPackage -Register -Path $pkg -DisableDevelopmentMode
    }
    else {
        Write-Warning "Missing path: $pkg"
    }
}

# Restart SiHost so changes are picked up
Write-Host "Restarting SiHost..."
Get-Process sihost -ErrorAction SilentlyContinue | Stop-Process -Force
# SiHost will auto-respawn as part of the shell
