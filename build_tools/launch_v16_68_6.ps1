param(
    [Parameter(Mandatory=$true)][string]$WorkingRoot,
    [string]$VfpExe='C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path -LiteralPath $WorkingRoot).Path
$snapshotRoot=Split-Path -Parent $PSScriptRoot
$prg=Join-Path $root 'build_v16_68_6.prg'
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'build_v16_68_6.prg') -Destination $prg -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'patch_letterbuilder_dataenv_v16_68_6.prg') -Destination (Join-Path $root 'patch_letterbuilder_dataenv_v16_68_6.prg') -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'patch_about_build_label_v16_68_6.prg') -Destination (Join-Path $root 'patch_about_build_label_v16_68_6.prg') -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'patch_patients_lc_only_v16_68_6.prg') -Destination (Join-Path $root 'patch_patients_lc_only_v16_68_6.prg') -Force
Copy-Item -LiteralPath (Join-Path $snapshotRoot 'development_v16_67\PROGRAMS\letter_word_guard.prg') -Destination (Join-Path $root 'MOSt\PROGRAMS\letter_word_guard.prg') -Force
Copy-Item -LiteralPath (Join-Path $snapshotRoot 'development_v16_67\PROGRAMS\openletterwriter.prg') -Destination (Join-Path $root 'MOSt\PROGRAMS\openletterwriter.prg') -Force
Copy-Item -LiteralPath (Join-Path $snapshotRoot 'development_v16_67\PROGRAMS\diagram_tool.prg') -Destination (Join-Path $root 'MOSt\PROGRAMS\diagram_tool.prg') -Force
Copy-Item -LiteralPath (Join-Path $snapshotRoot 'development_v16_67\PROGRAMS\consult_letter.prg') -Destination (Join-Path $root 'MOSt\PROGRAMS\consult_letter.prg') -Force
Copy-Item -LiteralPath (Join-Path $snapshotRoot 'development_v16_67\FORMS\letterform.scx') -Destination (Join-Path $root 'MOSt\FORMS\letterform.scx') -Force
Copy-Item -LiteralPath (Join-Path $snapshotRoot 'development_v16_67\FORMS\letterform.sct') -Destination (Join-Path $root 'MOSt\FORMS\letterform.sct') -Force
Copy-Item -LiteralPath (Join-Path $snapshotRoot 'development_v16_67\FORMS\enter_claims.scx') -Destination (Join-Path $root 'MOSt\FORMS\enter_claims.scx') -Force
Copy-Item -LiteralPath (Join-Path $snapshotRoot 'development_v16_67\FORMS\enter_claims.sct') -Destination (Join-Path $root 'MOSt\FORMS\enter_claims.sct') -Force
Copy-Item -LiteralPath (Join-Path $snapshotRoot 'development_v16_67\FORMS\patients.scx') -Destination (Join-Path $root 'MOSt\FORMS\patients.scx') -Force
Copy-Item -LiteralPath (Join-Path $snapshotRoot 'development_v16_67\FORMS\patients.sct') -Destination (Join-Path $root 'MOSt\FORMS\patients.sct') -Force
$fpw=Join-Path $root 'build_v16_68_6.fpw'
[IO.File]::WriteAllText($fpw,"SCREEN=OFF`r`nRESOURCE=OFF`r`nTALK=OFF`r`nSAFETY=OFF`r`nCOMMAND=DO `"$prg`" WITH `"$root`"`r`n",[Text.Encoding]::Default)
$started=Get-Date
$p=Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$fpw+'"')) -WorkingDirectory $root -WindowStyle Hidden -PassThru
if(-not $p.WaitForExit(180000)){throw 'V16.68.6 build did not finish.'}
$log=Join-Path $root 'output\build_v16_68_6.log'
$exe=Join-Path $root 'output\MOST_V16_68_6_SAME_VERSION_1_7_708_XP_TEST.exe'
if(-not (Test-Path -LiteralPath $log) -or (Get-Item -LiteralPath $log).LastWriteTime -lt $started){throw 'No fresh V16.68.6 build log.'}
if((Get-Content -LiteralPath $log -Raw) -notmatch 'SUCCESS V16\.68\.6 SAME VERSION 1\.7\.708 NO UPGRADE'){throw (Get-Content -LiteralPath $log -Raw)}
if(-not (Test-Path -LiteralPath $exe)){throw 'No V16.68.6 executable was produced.'}
Get-Item -LiteralPath $exe | Select-Object FullName,Length,@{N='Version';E={$_.VersionInfo.FileVersion}}
