
$fileversion = (Get-Item .\file1.exe).VersionInfo.FileVersion
$fileversionNetwork = (Get-Item .\parent\file1.exe).VersionInfo.FileVersion
Write-Host $fileversion
Write-Host $fileversionNetwork

Start-Sleep 3
if (!($fileversion -ge $fileversionNetwork)) {
    Invoke-Item (Start-Process powershell .\updater.ps1)
}
elseif (($fileversion -ge $fileversionNetwork)) {
    Write-Host "File is updated with $fileversion"
}
else {
    Write-Host "Failed update. Current version $fileversion"
}


