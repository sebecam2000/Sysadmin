# Variables
$logFile = "C:\temp\teams-uninst.txt"  # Chemin vers le fichier de log
$oldTeamsPath = "C:\Users\$env:USERNAME\AppData\Local\Microsoft\Teams\*.*"
$oldTeamsShortcut = "C:\users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft Teams classic.lnk"
$uninstallMarker = "C:\temp\TeamsUninstall-OK.txt"  # Fichier témoin

# Fonction de log
function Write-Log {
    param (
        [string]$message
    )
    $folderPath = "C:\temp"

    if (-not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
    Write-Output "Folder Created Successfully!"
    }
    else {
    Write-Output "Folder already exists!"
    }
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Output $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Fonction pour vérifier si Teams est désinstallé
function Check-Uninstall {
    if (!(Test-Path "C:\Users\$env:USERNAME\AppData\Local\Microsoft\Teams\update.exe")) {
        return $true
    } else {
        return $false
    }
}

# Fonction pour désinstaller l'ancien Teams
function Uninstall-OldTeams {
    Write-Log "Starting uninstallation of old Teams..."

    # Fermer Teams s'il est en cours d'exécution
    try {
        Stop-Process -Name Teams -Force -ErrorAction Stop
        #Start-Sleep -Seconds 5  # Ajout d'un délai pour s'assurer que le processus est complètement arrêté
        Get-Process -Name Teams -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction Stop
        #Start-Sleep -Seconds 5  # Ajout d'un délai pour s'assurer que le processus est complètement arrêté
        Write-Log "Teams process stopped."
    } catch {
        Write-Log "Teams process was not running."
    }

    # Supprimer l'installation de Teams
    if (Test-Path $oldTeamsPath) {
        try {
            Remove-Item -Path $oldTeamsPath -Recurse -Force -ErrorAction Stop
            Remove-Item $oldTeamsShortcut -Force
            Write-Log "Microsoft Teams found and uninstalled."
        } catch {
            Write-Log "Failed to uninstall Microsoft Teams. Error: $_"
            exit 1
        }
    } else {
        Write-Log "Microsoft Teams not found."
    }

    # Supprimer le Teams Machine-Wide Installer
    $TeamsMachineInstaller = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name = 'Teams Machine-Wide Installer'"
    if ($TeamsMachineInstaller) {
        try {
            $TeamsMachineInstaller.Uninstall()
            Write-Log "Teams Machine-Wide Installer uninstalled."
        } catch {
            Write-Log "Failed to uninstall Teams Machine-Wide Installer. Error: $_"
        }
    } else {
        Write-Log "Teams Machine-Wide Installer not found."
    }
    Write-Log "Old Teams uninstallation completed."
    if (Check-Uninstall) {
        Write-Log "Old Teams uninstallation completed."
        New-Item -Path $uninstallMarker -ItemType File | Out-Null
        exit 0
    } else {
        Write-Log "Uninstallation check failed. Teams still present."
        exit 1
    }
    #New-Item -Path "C:\temp\TeamsUninstall-OK.txt" -ItemType File

}

# Exécuter la fonction
Uninstall-OldTeams
