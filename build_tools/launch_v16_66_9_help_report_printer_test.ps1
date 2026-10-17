param([Parameter(Mandatory=$true)][string]$WorkingRoot,[string]$VfpExe='C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe')
$ErrorActionPreference='Stop'
$root=(Resolve-Path -LiteralPath $WorkingRoot).Path
$prg=Join-Path $root 'build_help_report_printer_test.prg'
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'build_v16_66_9_help_report_printer_test.prg') -Destination $prg -Force
$fpw=Join-Path $root 'build_help_report_printer_test.fpw'
[IO.File]::WriteAllText($fpw,"SCREEN=OFF`r`nRESOURCE=OFF`r`nTALK=OFF`r`nSAFETY=OFF`r`nCOMMAND=DO `"$prg`" WITH `"$root`"`r`n",[Text.Encoding]::Default)
$started=Get-Date
$p=Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$fpw+'"')) -WorkingDirectory $root -WindowStyle Hidden -PassThru
if(-not $p.WaitForExit(180000)){throw 'Help/report/printer test build did not finish.'}
$log=Join-Path $root 'output\build_v16_66_9_help_report_printer_test.log'
$exe=Join-Path $root 'output\MOST_V16_66_9_1_7_694_HELP_REPORT_PRINTER_TEST.exe'
if(-not (Test-Path $log) -or (Get-Item $log).LastWriteTime -lt $started){throw 'No fresh build log.'}
if((Get-Content $log -Raw) -notmatch 'SUCCESS HELP REPORT PRINTER TEST 1\.7\.694'){throw (Get-Content $log -Raw)}
Get-Item $exe | Select-Object FullName,Length,@{N='Version';E={$_.VersionInfo.FileVersion}}
