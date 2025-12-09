# Forcer le client RDP classique (mstsc.exe)
$regPath = "HKCU:\Software\Microsoft\Terminal Server Client"
$propName = "UseClassicRDP"
$propValue = 1

If (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

New-ItemProperty -Path $regPath -Name $propName -Value $propValue -PropertyType DWORD -Force | Out-Null
