# Définit les couleurs de la console
$console = $host.ui.RawUI
$console.ForegroundColor = "DarkYellow"
Clear-Host  # Rafraîchit la console pour appliquer les couleurs

Write-Host "Réinitialisation de l'adaptateur Ethernet en cours."

# Obtenir l'adaptateur Ethernet et le stocker dans une variable
$adapter = Get-NetAdapter -Name "Ethernet"

# Désactiver l'adaptateur Ethernet
$adapter | Disable-NetAdapter -Confirm:$false

Write-Host "Désactivation en cours..."
while ($adapter.Status -ne "Disabled") {
        Start-Sleep -Seconds 1
		$adapter = Get-NetAdapter -Name "Ethernet"
    }
Write-Host "Adaptateur désactivé."
Write-Host "Réactivation en cours."
# Réactiver l'adaptateur Ethernet
$adapter | Enable-NetAdapter -Confirm:$false
while ($adapter.Status -ne "Up") {
        Start-Sleep -Seconds 1
		$adapter = Get-NetAdapter -Name "Ethernet"
    }
Write-Host "Adaptateur Ethernet connecté."
# Message de confirmation
Write-Host "L'adaptateur Ethernet a été réinitialisé."
Start-Sleep -Seconds 1
Stop-Service -Name "Serviio"
Start-Sleep -Seconds 3
Start-Service -Name "Serviio"