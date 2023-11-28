# Définition du chemin de départ
$rootPath = "G:\Graphic novels"
$rootPathMangas = "G:\Graphic novels\Mangas"
$rootPathZip = "${rootPath}_zip"

# Fonction pour vérifier la présence d'au moins deux images dans un répertoire
function HasSomeImages($path) {
    $imageExtensions = @("*.jpg", "*.png", "*.jpeg","*.gif")
    $count = 0
    foreach ($ext in $imageExtensions) {
        $files = Get-ChildItem -LiteralPath $path -Filter $ext -File -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $count++
            if ($count -ge 2) {
                return $true
            }
        }
    }
    return $false
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
        if ($parentLeafDirectory.StartsWith("Mangas")) {
           $rootPathZip = "${rootPath}\${parentLeafDirectory}_zip"  # Ex: "G:\Graphic novels\Mangas - Genre_zip"
           Write-Host "rootPathZip : $rootPathZip" -ForegroundColor Yellow
        } else { # il y un sous répertoire ex: G:\Graphic novels\Mangas\Author\Album
            $rootPathZip = "${rootPathMangas}_zip"  
            Write-Host "rootPathZip : $rootPathZip" -ForegroundColor DarkYellow
        }
        
        $pathToCompress = $path
        $destinationZip = "${rootPathZip}\${titleDirectory}.zip"
        # Write-Host $destinationZip
        # Création de l'archive zip en utilisant 7-Zip
        Write-Host "Zipping : $pathToCompress" -ForegroundColor Red
        Write-Host "into $destinationZip" -ForegroundColor Red

        & "C:\Program Files (x86)\7-Zip\7z.exe" a -tzip $destinationZip $pathToCompress -r -mx0 -bso0
    } else {
        Write-Host $path -ForegroundColor White
    }
}

# Lancement du script
TraverseDirectory $rootPathMangas
