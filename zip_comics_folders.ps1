# Définition du chemin de départ
$rootPath = "G:\Graphic novels"
$mediaType = "Mangas"
$rootPathTree = "${rootPath}\${mediaType}"
$rootPathZip = "${rootPath}_zip"

# Fonction pour vérifier la présence d'au moins deux images dans un répertoire
function HasSomeImages($path) {
    $imageExtensions = @("*.jpg", "*.png", "*.jpeg", "*.gif")
    $count = (Get-ChildItem -LiteralPath $path -Include $imageExtensions -File -ErrorAction SilentlyContinue).Count
    return $count -ge 2
}


# Fonction pour parcourir l'arborescence récursivement
function TraverseDirectory($path) {  
    $subFolders = Get-ChildItem -LiteralPath $path -Directory -ErrorAction SilentlyContinue
    foreach ($folder in $subFolders) {
        TraverseDirectory $folder.FullName
    }
    
    if (HasSomeImages $path) {
        Write-Host $path -ForegroundColor Gray
        $parentPath = Split-Path -Path $path -Parent
        Write-Host "Parent : $parentPath" -ForegroundColor DarkMagenta
        $titleDirectory = Split-Path -Path $Path -Leaf
        $parentLeafDirectory = Split-Path -Path $parentPath -Leaf
        if ($parentLeafDirectory.StartsWith($mediaType)) {
           $rootPathZip = "${rootPath}\${parentLeafDirectory}_zip"  # Ex: "G:\Graphic novels\Mangas - Genre_zip"
           Write-Host "rootPathZip : $rootPathZip" -ForegroundColor Yellow
        } else { # il y un sous répertoire ex: G:\Graphic novels\Mangas\Author\Album
            $rootPathZip = "${rootPathTree}_zip"  
            Write-Host "rootPathZip : $rootPathZip" -ForegroundColor DarkYellow
        }
        
        $pathToCompress = $path
        $destinationZip = "${rootPathZip}\${titleDirectory}.zip"
        # Write-Host $destinationZip
        # Création de l'archive zip en utilisant 7-Zip
        Write-Host "Zipping : $pathToCompress" -ForegroundColor Red
        Write-Host "into $destinationZip" -ForegroundColor Red

       # & "C:\Program Files (x86)\7-Zip\7z.exe" a -tzip $destinationZip $pathToCompress -r -mx0 -bso0
    } else {
        Write-Host $path -ForegroundColor White
    }
}

# Lancement du script
TraverseDirectory $rootPathTree
