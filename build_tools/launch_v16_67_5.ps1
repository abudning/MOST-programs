param(
    [Parameter(Mandatory=$true)][string]$WorkingRoot,
    [string]$VfpExe='C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path -LiteralPath $WorkingRoot).Path
$prg=Join-Path $root 'build_v16_67_5.prg'
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'build_v16_67_5.prg') -Destination $prg -Force
$fpw=Join-Path $root 'build_v16_67_5.fpw'
[IO.File]::WriteAllText($fpw,"SCREEN=OFF`r`nRESOURCE=OFF`r`nTALK=OFF`r`nSAFETY=OFF`r`nCOMMAND=DO `"$prg`" WITH `"$root`"`r`n",[Text.Encoding]::Default)
$started=Get-Date
$p=Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$fpw+'"')) -WorkingDirectory $root -WindowStyle Hidden -PassThru
if(-not $p.WaitForExit(180000)){throw 'V16.67.5 build did not finish.'}
$log=Join-Path $root 'output\build_v16_67_5.log'
$exe=Join-Path $root 'output\MOST_V16_67_5_1_7_700_XP_TEST.exe'
if(-not (Test-Path -LiteralPath $log) -or (Get-Item -LiteralPath $log).LastWriteTime -lt $started){throw 'No fresh V16.67.5 build log.'}
if((Get-Content -LiteralPath $log -Raw) -notmatch 'SUCCESS V16\.67\.5 1\.7\.700'){throw (Get-Content -LiteralPath $log -Raw)}
if(-not (Test-Path -LiteralPath $exe)){throw 'No V16.67.5 executable was produced.'}
Get-Item -LiteralPath $exe | Select-Object FullName,Length,@{N='Version';E={$_.VersionInfo.FileVersion}}
