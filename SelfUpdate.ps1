function UpdateSctipt {

    $ScriptVersion = "39"

    Write-Output $ScriptVersion
    $CurrentDirectory = Get-Location
    write-host $CurrentDirectory


    $RepoOwner = 'nmpereira'
    $Repository = 'PowerShellTest'
    $ScriptUpdaterFileName = 'SelfUpdate.ps1'


    $Ps2ExeConvert = 'ps2execonvert.ps1'
    $Tempfolder = 'C:\temp\UpdateScript'
    $varfile = join-path -path $Tempfolder -childpath 'ScriptScriptVersion.txt'
    $CurrentDirectory | Set-Content $varfile
    $Ps2ExeConvertpath = join-path $Tempfolder -childpath $Ps2ExeConvert


    $ScriptVersionlog = $varfile = join-path -path $Tempfolder -childpath 'ScriptVersion.txt'
    $ScriptVersion | Set-Content $ScriptVersionlog
    function DownloadFilesFromRepo {

        $baseUri = "https://api.github.com/"
        $UriArgs = "repos/$RepoOwner/$Repository/contents/$ScriptUpdaterFileName"

        try {
            $wr = Invoke-WebRequest -Uri $($baseuri + $UriArgs) -ErrorAction Stop -UseBasicParsing
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
    
        $files = $objects | Where-Object { $_.type -eq "file" } | Select-Object -exp download_url
        $directories = $objects | Where-Object { $_.type -eq "dir" }
    
        $directories | ForEach-Object { 
            DownloadFilesFromRepo -Owner $RepoOwner -Repository $Repository -Path $_.path -DestinationPath $($Tempfolder + $_.name)
        }

    
        if (-not (Test-Path $Tempfolder)) {
            # Destination path does not exist, let's create it
            try {
                New-Item -Path $Tempfolder -ItemType Directory -ErrorAction Stop
            }
            catch {
                throw "Could not create path '$Tempfolder'!"
            }
        }

        foreach ($file in $files) {
            $fileDestination = Join-Path $Tempfolder (Split-Path $file -Leaf)
            try {
                Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop -Verbose
                "Grabbed '$($file)' to '$fileDestination'"
            }
            catch {
                throw "Unable to download '$($file.path)'"
            }
        }

    }

    ##################
    $scriptwrite = @'
    install-module ps2exe -force
    $UpdaterPath = 'C:\temp\UpdateScript'
    $varfile = join-path -path $UpdaterPath -childpath 'ScriptScriptVersion.txt'
    $CurrentDirectory = get-content $varfile
    $ScriptUpdaterFileName= 'SelfUpdate.ps1'
    $DestFullpath = join-path $UpdaterPath -childpath $ScriptUpdaterFileName
    
    #$script:scriptpath = join-path $UpdaterPath -childpath $ScriptUpdaterFileName
    $script:UpdaterPathexe = join-path $CurrentDirectory -childpath 'SelfUpdate.exe'
    taskkill /IM SelfUpdate.exe /F
    ps2exe -inputfile $DestFullpath -outputfile $UpdaterPathexe
'@
    ##################
    $scriptwrite | Set-Content $Ps2ExeConvertpath 
    ##################

    (DownloadFilesFromRepo)

    try {
        Invoke-Item (Start-Process powershell $Ps2ExeConvertpath -verb runas)
    }
    catch {
    
    } 


}

(UpdateSctipt)
