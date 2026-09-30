param(
    [Parameter(Mandatory=$true)][string]$ClassesPath,
    [string]$VfpExe = 'C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference = 'Stop'
$classes = (Resolve-Path -LiteralPath $ClassesPath).Path
if (-not (Test-Path -LiteralPath (Join-Path $classes 'tools.vcx'))) { throw 'tools.vcx was not found.' }
if (-not (Test-Path -LiteralPath $VfpExe)) { throw 'Visual FoxPro 9 executable was not found.' }
$patchScript = Join-Path $PSScriptRoot 'patch_waitinglist_find_v16_64_5.prg'
$configPath = Join-Path $env:TEMP 'most_patch_waitinglist_v16_64_5.fpw'
$config = "SCREEN=OFF`r`nRESOURCE=OFF`r`nTALK=OFF`r`nSAFETY=OFF`r`nCOMMAND=DO `"$patchScript`" WITH `"$classes`"`r`n"
[System.IO.File]::WriteAllText($configPath,$config,[System.Text.Encoding]::Default)
$process = Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$configPath+'"')) -WindowStyle Hidden -PassThru
if (-not $process.WaitForExit(60000)) {
    throw 'The Waiting List class patch did not finish within 60 seconds.'
}
if ($process.ExitCode -ne 0) { throw "Visual FoxPro class patch failed with exit code $($process.ExitCode)." }
