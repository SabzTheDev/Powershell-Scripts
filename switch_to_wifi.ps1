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
if ($wifiStatus -eq "Up" -and $ethernetStatus -eq "Disabled") {
    Write-Output "Le wifi est déjà activé et connecté"
    return
}

# Désactive l'adaptateur Ethernet s'il n'est pas déjà désactivé
Write-Output "Désactivation de l'adaptateur Ethernet..."
Get-NetAdapter -Name "Ethernet" | Disable-NetAdapter -Confirm:$false
Write-Output "Adaptateur Ethernet désactivé."

# Active l'adaptateur Wi-Fi s'il est désactivé
Write-Output "Activation de de l'adaptateur wifi..."
Get-NetAdapter -Name "Wi-Fi" | Enable-NetAdapter -Confirm:$false
# Attend que l'adaptateur Wi-Fi soit en état non "Disabled"
while ((Get-NetAdapter -Name "Wi-Fi").Status -eq "Disabled") {
    Start-Sleep -Seconds 1
}


# Se connecte au réseau Wi-Fi spécifié
Write-Output "Connection au wifi SFR_1BF8..."
Netsh WLAN connect name="SFR_1BF8"
while ((Get-NetAdapter -Name "Wi-Fi").Status -ne "Up") {
    Start-Sleep -Seconds 1
}
Write-Output "Connecté."
Start-Sleep -Seconds 1