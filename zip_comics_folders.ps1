
# Execute le traitement sur l'arborescence.
function ProcessTree([string]$rootPathTree) {
    TraverseDirectory $rootPathTree
}

# Verifie qu'un répertoire ne contient pas de fichier (mais il doit contenir des répertoires)
function Test-DirectoryIsParent([string]$directoryPath) {
    $hasFiles = Get-ChildItem -Path $directoryPath -File | Select-Object -First 1
    $hasSubdirectories = Get-ChildItem -Path $directoryPath -Directory | Select-Object -First 1
    $hasNoFiles = $null -eq $hasFiles
    $hasAtLeastOneSubdirectory = $null -ne $hasSubdirectories
    return $hasNoFiles -and $hasAtLeastOneSubdirectory
}

# Déduit le chemin de destination à partir du chemin courant et du répertoire racine.
# Ex : 
#  currentPath = G:\Graphic novels\Mangas\Nukaji Wizakun - Tropical Bitch
#  rootPath = G:\Graphic novels\Mangas
# return G:\Graphic novels\Mangas_zip\Nukaji Wizakun - Tropical Bitch
function Convert-PathToZipPath ([string]$currentPath, [string]$rootPathTree) {
    $searchString= $rootPathTree
    $replaceString= "${rootPathTree}_zip" # On suffixe le répertoire racine avec _zip
    if ($currentPath.StartsWith($rootPathTree)) {
        return $currentPath.Replace($searchString, $replaceString)
    } else {
        throw "Le chemin fourni ne commence pas par le chemin de base attendu."
    }
}


# Fonction pour parcourir les sous répertoires de 1er niveau de l'arborescence.
# Les répertoires de 1er niveau son zippés, les répertoires qui commencent par _ sont explorés récursivement.
function TraverseDirectory([string]$referenceTree) {  
    $subFolders = Get-ChildItem -LiteralPath $referenceTree -Directory -ErrorAction SilentlyContinue
    foreach ($subFolder in $subFolders) {
        $subFolderPath = $subFolder.FullName
        if (Test-DirectoryIsParent $subFolderPath) {
            Write-Host "Exploration du dossier: $($subFolder.Name)" -ForegroundColor Red
        
            TraverseDirectory $subFolderPath
            continue  # Passe à la prochaine itération de la boucle
        }
        $destinationPath = Convert-PathToZipPath -currentPath $subFolderPath -rootPathTree $rootPathTree
        $pathToCompress = $subFolderPath
        $destinationZip = "${destinationPath}.zip"
        Write-Host "Zipping : $destinationZip"
        Write-Host $subFolder -ForegroundColor Yellow -NoNewline
        Write-Host " zipped" -ForegroundColor Green
        & "C:\Program Files (x86)\7-Zip\7z.exe" a -tzip $destinationZip $pathToCompress -r -mx0 -bso0
    }
}

# Lancement du script
#ProcessTree "G:\Graphic novels\Comics"
ProcessTree "G:\Graphic novels\Mangas"
