$sounds = @{
    "click.mp3" = "https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3"
    "win.mp3" = "https://assets.mixkit.co/active_storage/sfx/1435/1435-preview.mp3"
    "lose.mp3" = "https://assets.mixkit.co/active_storage/sfx/2658/2658-preview.mp3"
}

foreach ($sound in $sounds.GetEnumerator()) {
    $outputPath = "assets/sounds/$($sound.Key)"
    Write-Host "Downloading $($sound.Key)..."
    Invoke-WebRequest -Uri $sound.Value -OutFile $outputPath
} 