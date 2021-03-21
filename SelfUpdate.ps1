Write-host $PSScriptRoot
Echo "v13"

function DownloadFilesFromRepo {
#Param(
    $Owner= 'nmpereira'
    $Repository='PowerShellTest'
    $Path= 'test1.ps1'
    $DestinationPath= 'C:\Gitpersonal\testcode'
    $script:scriptpath = join-path $DestinationPath -childpath $Path
    $script:DestinationPathexe = join-path $DestinationPath -childpath 'test1.exe'
    $script:ps2execonvert= 'ps2execonvert.ps1'
	$script:ps2execonvertpath = join-path $DestinationPath -childpath $ps2execonvert
    #)

    $baseUri = "https://api.github.com/"
    $args = "repos/$Owner/$Repository/contents/$Path"

    try {
        $wr = Invoke-WebRequest -Uri $($baseuri+$args) -ErrorAction Stop
    }
    catch {
        write-host "cannot access webrequest"
    }
    try {
        $objects = $wr.Content | ConvertFrom-Json
    }
    catch {
        write-host "cannot convert to Json"
    }
    
    $files = $objects | where {$_.type -eq "file"} | Select -exp download_url
    $directories = $objects | where {$_.type -eq "dir"}
    
    $directories | ForEach-Object { 
        DownloadFilesFromRepo -Owner $Owner -Repository $Repository -Path $_.path -DestinationPath $($DestinationPath+$_.name)
    }

    
    if (-not (Test-Path $DestinationPath)) {
        # Destination path does not exist, let's create it
        try {
            New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop
        } catch {
            throw "Could not create path '$DestinationPath'!"
        }
    }

    foreach ($file in $files) {
        $fileDestination = Join-Path $DestinationPath (Split-Path $file -Leaf)
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

    $Path= 'test1.ps1'
    $DestinationPath= 'C:\Gitpersonal\testcode'
    $script:scriptpath = join-path $DestinationPath -childpath $Path
    $script:DestinationPathexe = join-path $DestinationPath -childpath 'test1.exe'


taskkill /IM test1.exe /F
start-sleep 3
ps2exe -inputfile $scriptpath -outputfile $DestinationPathexe
'@

$scriptwrite | Set-Content ./convertertest.ps1 

############

(DownloadFilesFromRepo)
start-sleep 5
#taskkill /IM Test1.EXE /F
#& "$DestinationPath\ps2execonvert.ps1"
 Invoke-Item (start powershell $ps2execonvertpath)
#invoke-ps2exe -inputfile $scriptpath -outputfile $DestinationPathexe
#Start-Process -FilePath "Test1.exe"

pause
