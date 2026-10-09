param(
    [Parameter(Mandatory=$true)][string]$WorkingRoot,
    [string]$VfpExe = 'C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference = 'Stop'
$buildRoot = (Resolve-Path -LiteralPath $WorkingRoot).Path
if (-not (Test-Path -LiteralPath (Join-Path $buildRoot 'MOSt\most.pjx'))) { throw 'An isolated full source copy containing MOSt\most.pjx is required.' }
if (-not (Test-Path -LiteralPath $VfpExe)) { throw 'Visual FoxPro 9 executable was not found.' }
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'build_v16_66_6.prg') -Destination (Join-Path $buildRoot 'build_v16_66_6.prg') -Force
$configPath = Join-Path $buildRoot 'build_v1666_explicit.fpw'
$buildScript = Join-Path $buildRoot 'build_v16_66_6.prg'
$config = "SCREEN=OFF`r`nRESOURCE=OFF`r`nTALK=OFF`r`nSAFETY=OFF`r`nCOMMAND=DO `"$buildScript`" WITH `"$buildRoot`"`r`n"
[System.IO.File]::WriteAllText($configPath,$config,[System.Text.Encoding]::Default)
$buildStarted = Get-Date
$buildProcess = Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$configPath+'"')) -WorkingDirectory $buildRoot -WindowStyle Hidden -PassThru
if (-not $buildProcess.WaitForExit(180000)) {
    throw "FoxPro build process $($buildProcess.Id) has not finished. Inspect its Locate File dialog; do not start another build over the same project."
}
$logPath = Join-Path $buildRoot 'output\build_v16_66_6.log'
$exePath = Join-Path $buildRoot 'output\MOST_V16_66_6_1_7_692_TEST.exe'
if (-not (Test-Path -LiteralPath $logPath) -or (Get-Item -LiteralPath $logPath).LastWriteTime -lt $buildStarted) { throw 'The intended build script did not produce a fresh log.' }
if ((Get-Content -LiteralPath $logPath -Raw) -notmatch 'SUCCESS V16\.66\.6 1\.7\.692') { throw (Get-Content -LiteralPath $logPath -Raw) }
if (-not (Test-Path -LiteralPath $exePath) -or (Get-Item -LiteralPath $exePath).LastWriteTime -lt $buildStarted) { throw 'A fresh executable was not produced.' }
Get-Item -LiteralPath $exePath | Select-Object FullName,Length,@{Name='Version';Expression={$_.VersionInfo.FileVersion}}
