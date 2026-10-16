param(
    [Parameter(Mandatory=$true)][string]$WorkingRoot,
    [string]$VfpExe = 'C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference = 'Stop'
$buildRoot = (Resolve-Path -LiteralPath $WorkingRoot).Path
$sourceScript = Join-Path $PSScriptRoot 'build_v16_66_8_printer_trace_diagnostic.prg'
$buildScript = Join-Path $buildRoot 'build_printer_trace.prg'
Copy-Item -LiteralPath $sourceScript -Destination $buildScript -Force
$configPath = Join-Path $buildRoot 'build_printer_trace.fpw'
$config = "SCREEN=OFF`r`nRESOURCE=OFF`r`nTALK=OFF`r`nSAFETY=OFF`r`nCOMMAND=DO `"$buildScript`" WITH `"$buildRoot`"`r`n"
[System.IO.File]::WriteAllText($configPath,$config,[System.Text.Encoding]::Default)
$buildStarted = Get-Date
$buildProcess = Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$configPath+'"')) -WorkingDirectory $buildRoot -WindowStyle Hidden -PassThru
if (-not $buildProcess.WaitForExit(180000)) { throw 'Visual FoxPro printer-trace build did not finish.' }
$logPath = Join-Path $buildRoot 'output\build_v16_66_8_printer_trace_diagnostic.log'
$exePath = Join-Path $buildRoot 'output\MOST_V16_66_8_1_7_694_PRINTER_TRACE_DIAGNOSTIC.exe'
if (-not (Test-Path -LiteralPath $logPath) -or (Get-Item -LiteralPath $logPath).LastWriteTime -lt $buildStarted) { throw 'No fresh printer-trace build log was produced.' }
if ((Get-Content -LiteralPath $logPath -Raw) -notmatch 'SUCCESS V16\.66\.8 PRINTER TRACE DIAGNOSTIC 1\.7\.694') { throw (Get-Content -LiteralPath $logPath -Raw) }
if (-not (Test-Path -LiteralPath $exePath) -or (Get-Item -LiteralPath $exePath).LastWriteTime -lt $buildStarted) { throw 'No fresh printer-trace executable was produced.' }
Get-Item -LiteralPath $exePath | Select-Object FullName,Length,@{Name='Version';Expression={$_.VersionInfo.FileVersion}}
