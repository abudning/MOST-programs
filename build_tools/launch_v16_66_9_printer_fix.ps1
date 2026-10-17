param(
    [Parameter(Mandatory=$true)][string]$WorkingRoot,
    [string]$VfpExe = 'C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference = 'Stop'
$buildRoot = (Resolve-Path -LiteralPath $WorkingRoot).Path
$sourceScript = Join-Path $PSScriptRoot 'build_v16_66_9_printer_fix.prg'
$buildScript = Join-Path $buildRoot 'build_v16_66_9_printer_fix.prg'
Copy-Item -LiteralPath $sourceScript -Destination $buildScript -Force
$configPath = Join-Path $buildRoot 'build_v16_66_9_printer_fix.fpw'
$config = "SCREEN=OFF`r`nRESOURCE=OFF`r`nTALK=OFF`r`nSAFETY=OFF`r`nCOMMAND=DO `"$buildScript`" WITH `"$buildRoot`"`r`n"
[IO.File]::WriteAllText($configPath,$config,[Text.Encoding]::Default)
$started=Get-Date
$p=Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$configPath+'"')) -WorkingDirectory $buildRoot -WindowStyle Hidden -PassThru
if(-not $p.WaitForExit(180000)){throw 'V16.66.9 build did not finish.'}
$log=Join-Path $buildRoot 'output\build_v16_66_9_printer_fix.log'
$exe=Join-Path $buildRoot 'output\MOST_V16_66_9_1_7_695_PRINTER_FIX_RC.exe'
if(-not (Test-Path $log) -or (Get-Item $log).LastWriteTime -lt $started){throw 'No fresh build log.'}
if((Get-Content $log -Raw) -notmatch 'SUCCESS V16\.66\.9 PRINTER FIX 1\.7\.695'){throw (Get-Content $log -Raw)}
if(-not (Test-Path $exe)){throw 'No V16.66.9 executable.'}
Get-Item $exe | Select-Object FullName,Length,@{N='Version';E={$_.VersionInfo.FileVersion}}
