
# $ROOT_SOURCE_PATH = "G:\Graphic novels"

# Fonction pour compresser les dossiers dans un chemin donné
function Compress-Folders ($sourcePath) {
    # Définition du chemin d'accès au répertoire de destination pour les archives zip
    $parentPath = Split-Path -Path $sourcePath -Parent
    $leafDirectory = Split-Path -Path $sourcePath -Leaf
    $destinationPath = "${parentPath}\${leafDirectory}_zip"

    Write-Host ""
    Write-Host "Compression des répertoires pour : '$destinationPath'"

    # Parcourt uniquement les dossiers de premier niveau dans le répertoire source
    Get-ChildItem -LiteralPath $sourcePath -Directory | ForEach-Object {
        $folder = $_ # Stocke le dossier courant

        # Construction du chemin complet du fichier zip pour chaque dossier
        $zipFile = "$destinationPath\$($folder.Name).zip"

        # Vérifie si le fichier zip existe déjà
        if (Test-Path -LiteralPath $zipFile) {
            Write-Host "Le fichier zip '$zipFile' existe déjà." -ForegroundColor DarkGray
            return
        }

        # Création de l'archive zip en utilisant 7-Zip
        Write-Host "Zipping : $($folder.FullName) into $($zipFile)" -ForegroundColor Green
        & "C:\Program Files (x86)\7-Zip\7z.exe" a -tzip $zipFile "$($folder.FullName)" -r -mx0
    }

     # Vérification des fichiers ZIP sans dossier correspondant
     Write-Host "Vérification des archives zip orphelines dans '$destinationPath'."

     # Détection des fichiers zip orphelins.
     if (Test-Path -LiteralPath $destinationPath) {
         # Parcourt tous les fichiers ZIP dans le répertoire de destination
         Get-ChildItem -LiteralPath $destinationPath -Filter *.zip | ForEach-Object {
            # $_.BaseName est le fichier zip sans extension, ce qui correspond aussi au nom du répertoire à vérifier.
             $matchingFolder = Join-Path -Path $sourcePath -ChildPath $_.BaseName

             # Vérifie si le dossier correspondant existe
             if (-not (Test-Path -LiteralPath $matchingFolder)) {
                 Write-Host "Suppression de l'archive orpheline '$($_.FullName)'." -ForegroundColor Red
                 Remove-Item -LiteralPath $_.FullName
             }
         }
     } else {
         Write-Host "Le répertoire de destination '$destinationPath' n'existe pas." -ForegroundColor Yellow
     }
 }


# Parcourt tous les sous-répertoires de premier niveau de G:\Graphic novels
Get-ChildItem -LiteralPath $ROOT_SOURCE_PATH -Directory | ForEach-Object {
    $subDirPath = $_.FullName
    Write-Host "Traitement du répertoire : $subDirPath"
    Compress-Folders -sourcePath $subDirPath
}