﻿
# Execute le traitement sur l'arborescence.
function ProcessTree([string]$_targetPath) {
    $global:rootPath = Split-Path -Path $_targetPath -Parent
    $global:mediaType = Split-Path -Path $_targetPath -Leaf
    $rootPathTree = "${rootPath}\${mediaType}"
    TraverseDirectory $rootPathTree
}

# Fonction pour vérifier la présence d'au moins deux images dans un répertoire
function HasSomeImages($path) {
    $imageExtensions = @("*.jpg", "*.png", "*.jpeg", "*.gif")
    $count = (Get-ChildItem -LiteralPath $path -Include $imageExtensions -File -ErrorAction SilentlyContinue).Count
    return $count -ge 2
}

# Fonction pour parcourir les sous répertoires de 1er niveau de l'arborescence.
# Les répertoires de 1er niveau son zippés, les répertoires qui commencent par _ sont explorés récursivement.
function TraverseDirectory([string]$path, [string]$optionalParentName='') {  
    $subFolders = Get-ChildItem -LiteralPath $path -Directory -ErrorAction SilentlyContinue
    foreach ($subFolder in $subFolders) {
        $subFolderPath = $subFolder.FullName
        # Lorsqu'un réprtoire commence par _, ca veut dire qu'il faut l'explorer et intégrer ce répertoire au path de destination.
        if ($subFolder.Name.StartsWith("_")) {
            $parentNameToPass = $subFolder.Name.Substring(1)  # Supprime le premier caractère "_"
            Write-Host "Exploration du dossier: $($subFolder.Name)" -ForegroundColor Red
            TraverseDirectory $subFolderPath  $parentNameToPass
            continue  # Passe à la prochaine itération de la boucle
        }
        $destinationPath = "${rootPathTree}_zip"  
        $pathToCompress = $subFolderPath
        if ($optionalParentName -eq '') {
            $destinationZip = "${destinationPath}\${subFolder}.zip"
        } else {
            $destinationZip = "${destinationPath}\${optionalParentName}\${subFolder}.zip"
        }        
        Write-Host "Zipping : $destinationZip"
        Write-Host $subFolder -ForegroundColor DarkYellow -NoNewline
        Write-Host " zipped" -ForegroundColor Green
        & "C:\Program Files (x86)\7-Zip\7z.exe" a -tzip $destinationZip $pathToCompress -r -mx0 -bso0
    }
}

# Lancement du script
#ProcessTree "G:\Graphic novels\Comics"
ProcessTree "G:\Graphic novels\Mangas"
