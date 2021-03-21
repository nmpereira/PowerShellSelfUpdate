Write-host $PSScriptRoot

$version= "35"

Write-Output $version
$DestinationPath = Get-Location
write-host $DestinationPath


$RepoOwner= 'nmpereira'
$Repository='PowerShellTest'
$Filename= 'test1.ps1'

#$script:scriptpath = join-path $DestinationPath -childpath $Filename
#$DestinationPathexe = join-path $DestinationPath -childpath 'test1.exe'
$ps2execonvert= 'ps2execonvert.ps1'
$Tempfolder ='C:\temp\test'
$varfile = join-path -path $Tempfolder -childpath 'variable.txt'
$DestinationPath | Set-Content $varfile
$ps2execonvertpath = join-path $Tempfolder -childpath $ps2execonvert


$versionlog= $varfile = join-path -path $Tempfolder -childpath 'version.txt'
$version | Set-Content $versionlog
function DownloadFilesFromRepo {
#Param(

    #)

    $baseUri = "https://api.github.com/"
    $args = "repos/$RepoOwner/$Repository/contents/$Filename"

    try {
        $wr = Invoke-WebRequest -Uri $($baseuri+$args) -ErrorAction Stop
    }
    catch {
        write-host "cannot access webrequest"
    }
    try {
        $objects = $wr.Content | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        write-host "cannot convert to Json"
    }
    
    $files = $objects | Where-Object {$_.type -eq "file"} | Select-Object -exp download_url
    $directories = $objects | Where-Object {$_.type -eq "dir"}
    
    $directories | ForEach-Object { 
        DownloadFilesFromRepo -Owner $RepoOwner -Repository $Repository -Path $_.path -DestinationPath $($Tempfolder+$_.name)
    }

    
    if (-not (Test-Path $Tempfolder)) {
        # Destination path does not exist, let's create it
        try {
            New-Item -Path $Tempfolder -ItemType Directory -ErrorAction Stop
        } catch {
            throw "Could not create path '$Tempfolder'!"
        }
    }

    foreach ($file in $files) {
        $fileDestination = Join-Path $Tempfolder (Split-Path $file -Leaf)
        try {
            Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop -Verbose
            "Grabbed '$($file)' to '$fileDestination'"
        } catch {
            throw "Unable to download '$($file.path)'"
        }
    }

}

##################
$scriptwrite = @'
install-module ps2exe -force
    $UpdaterPath = 'C:\temp\test'
    $varfile = join-path -path $UpdaterPath -childpath 'variable.txt'
    $DestinationPath = get-content $varfile
    $Filename= 'test1.ps1'
    $DestFullpath = join-path $UpdaterPath -childpath $Filename
    
    #$script:scriptpath = join-path $UpdaterPath -childpath $Filename
    $script:UpdaterPathexe = join-path $DestinationPath -childpath 'test1.exe'
    write-host '###'
    write-host $varfile
    write-host '###'
    write-host $DestFullpath
    write-host '###'
    write-host $UpdaterPathexe
    write-host '###'

taskkill /IM test1.exe /F
ps2exe -inputfile $DestFullpath -outputfile $UpdaterPathexe


'@

$scriptwrite | Set-Content $ps2execonvertpath 

############

(DownloadFilesFromRepo)

#taskkill /IM Test1.EXE /F
#& "$UpdaterPath\ps2execonvert.ps1"
try {
    Invoke-Item (Start-Process powershell $ps2execonvertpath -verb runas)
}
catch {
    
} 


#invoke-ps2exe -inputfile $scriptpath -outputfile $UpdaterPathexe
#Start-Process -FilePath "Test1.exe"

