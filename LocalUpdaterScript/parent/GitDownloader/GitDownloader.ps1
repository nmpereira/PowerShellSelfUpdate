$url ='https://raw.githubusercontent.com/nmpereira/PowerShellSelfUpdate/main/LocalUpdaterScript/parent/File1.exe'

#Invoke-WebRequest -uri $($url) -UseBasicParsing

$webClient = New-Object System.Net.WebClient

$file= Split-Path $url -Leaf
Write-Host $file
$webClient.DownloadFile($url,$file)

pause