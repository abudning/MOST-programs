param(
    [Parameter(Mandatory=$true)][string]$WorkingRoot,
    [string]$VfpExe='C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path -LiteralPath $WorkingRoot).Path
$prg=Join-Path $root 'build_v16_68_6.prg'
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'build_v16_68_6.prg') -Destination $prg -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'patch_letterbuilder_dataenv_v16_68_6.prg') -Destination (Join-Path $root 'patch_letterbuilder_dataenv_v16_68_6.prg') -Force
$fpw=Join-Path $root 'build_v16_68_6.fpw'
[IO.File]::WriteAllText($fpw,"SCREEN=OFF`r`nRESOURCE=OFF`r`nTALK=OFF`r`nSAFETY=OFF`r`nCOMMAND=DO `"$prg`" WITH `"$root`"`r`n",[Text.Encoding]::Default)
$started=Get-Date
$p=Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$fpw+'"')) -WorkingDirectory $root -WindowStyle Hidden -PassThru
if(-not $p.WaitForExit(180000)){throw 'V16.68.6 build did not finish.'}
$log=Join-Path $root 'output\build_v16_68_6.log'
$exe=Join-Path $root 'output\MOST_V16_68_6_1_7_709_XP_TEST.exe'
if(-not (Test-Path -LiteralPath $log) -or (Get-Item -LiteralPath $log).LastWriteTime -lt $started){throw 'No fresh V16.68.6 build log.'}
if((Get-Content -LiteralPath $log -Raw) -notmatch 'SUCCESS V16\.68\.6 1\.7\.709'){throw (Get-Content -LiteralPath $log -Raw)}
if(-not (Test-Path -LiteralPath $exe)){throw 'No V16.68.6 executable was produced.'}
Get-Item -LiteralPath $exe | Select-Object FullName,Length,@{N='Version';E={$_.VersionInfo.FileVersion}}
