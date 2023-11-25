# Définit les couleurs de la console
$console = $host.ui.RawUI
$console.ForegroundColor = "DarkYellow"
Clear-Host  # Rafraîchit la console pour appliquer les couleurs

# Force l'encodage de sortie à UTF-8
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Stocke l'état des adaptateurs Wi-Fi et Ethernet dans des variables
$wifiStatus = (Get-NetAdapter -Name "Wi-Fi").Status
$ethernetStatus = (Get-NetAdapter -Name "Ethernet").Status

# Vérifie si l'état de l'adaptateur Wi-Fi est "Up" et si l'état de l'adaptateur Ethernet est "Disabled"
if ($ethernetStatus -eq "Up") {
    Write-Output "Ethernet est déjà activé et connecté"
    return
}

# Désactivation de l'adapteteur Wifi
if ($wifiStatus -ne "Disabled") {
	Write-Output "Désactivation de de l'adaptateur wifi..."
    Get-NetAdapter -Name "Wi-Fi" | Disable-NetAdapter -Confirm:$false
    # Attend que l'adaptateur Wi-Fi soit en état "Disabled"
    while ((Get-NetAdapter -Name "Wi-Fi").Status -ne "Disabled") {
        Start-Sleep -Seconds 1
    }
	Write-Output "Adaptateur wifi désactivé."
}

# Active l'adaptateur Ethernet.
if ($ethernetStatus -eq "Disabled") {
    Write-Output "Activation de l'adaptateur Ethernet..."
    Get-NetAdapter -Name "Ethernet" | Enable-NetAdapter -Confirm:$false
	Write-Output "Adaptateur Ethernet activé."
}

# Nom du service
$serviceName = "Serviio"

# Arrêt du service
Write-Output "Arrêt du service Serviio"
Stop-Service -Name $serviceName -ErrorAction Stop

# Attente jusqu'à ce que le service soit complètement arrêté
do {
    Start-Sleep -Seconds 1
    $serviceStatus = Get-Service -Name $serviceName | Select-Object -ExpandProperty Status
} while ($serviceStatus -ne 'Stopped')

# Démarrage du service
Write-Output "Démarrage du service Serviio"
Start-Service -Name $serviceName
Get-Service -Name $serviceName | Select-Object -ExpandProperty Status

