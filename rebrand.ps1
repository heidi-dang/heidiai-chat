# Rebranding Script for heidiai to HeidiAI
# Fixed for dynamic path handling

# Define replacements
$replacements = @{
    "heidiai" = "heidiai"
    "https://github.com/heidi-dang/heidiai-chat" = "https://github.com/heidi-dang/heidiai-chat"
}

# File extensions to process
$extensions = @(".txt",".md",".json",".yml",".yaml",".js",".ts",".html",".svelte",".css",".config",".env",".py",".sh",".bat",".ps1",".xml")

# Step 1: Rename files/folders containing "heidiai"
Write-Host "Step 1: Renaming files and folders..."
$allItems = Get-ChildItem -Recurse -Force | Sort-Object FullName -Descending
foreach ($item in $allItems) {
    if ($item.Name -like "*heidiai*") {
        $newName = $item.Name -replace "heidiai", "heidiai"
        try {
            Write-Host "Renaming $($item.FullName) -> $newName"
            Rename-Item $item.FullName $newName
        } catch {
            Write-Host "Failed to rename $($item.FullName): $($_.Exception.Message)"
        }
    }
}

# Step 2: Process file contents
Write-Host "Step 2: Updating file contents..."
Get-ChildItem -Recurse -File -Force | Where-Object {
    $ext = $_.Extension.ToLower()
    $extensions -contains $ext -or $ext -eq ""
} | ForEach-Object {
    $file = $_
    try {
        # Read content safely
        $content = [System.IO.File]::ReadAllText($file.FullName)
        $updated = $false
        
        # Apply all replacements
        foreach ($key in $replacements.Keys) {
            if ($content -like "*$key*") {
                Write-Host "Updating $($file.FullName)"
                $content = $content -replace [regex]::Escape($key), $replacements[$key]
                $updated = $true
            }
        }

        # Write back if changed
        if ($updated) {
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        }
    } catch {
        Write-Host "Skipping $($file.FullName): $($_.Exception.Message)"
    }
}

Write-Host "Rebranding completed successfully!"
