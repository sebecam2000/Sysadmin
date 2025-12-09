# Disable SmartAppControl (SAC)
# Définition du chemin de la clé CI Policy
$CIPolicyKey = "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy"

# Vérifier si la clé existe
if (Test-Path $CIPolicyKey) {
    Write-Host "CI Policy Key Found. Forcing Smart App Control OFF..."
    Set-ItemProperty -Path $CIPolicyKey -Name "VerifiedAndReputablePolicyState" -Value 0 -Type DWord -Force
} 
