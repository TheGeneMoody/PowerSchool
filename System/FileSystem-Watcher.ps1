$pathToWatch = "C:\temp"  # Change to your target directory
$filter = "*"                      # Monitor all files

# Create the FileSystemWatcher object
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $pathToWatch
$watcher.Filter = $filter
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Define event handlers
Register-ObjectEvent $watcher "Changed" -Action {
    Write-Host "File Changed: $($EventArgs.FullPath)"
}
Register-ObjectEvent $watcher "Created" -Action {
    Write-Host "File Created: $($EventArgs.FullPath)"
}
Register-ObjectEvent $watcher "Deleted" -Action {
    Write-Host "File Deleted: $($EventArgs.FullPath)"
}
Register-ObjectEvent $watcher "Renamed" -Action {
    Write-Host "File Renamed: $($EventArgs.OldFullPath) -> $($EventArgs.FullPath)"
}

Write-Host "Watching for changes in $pathToWatch. Press Ctrl+C to stop."

# Infinite loop to keep processing events
while ($true) {
    Start-Sleep -Seconds 1
}
