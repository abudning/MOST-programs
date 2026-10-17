param(
    [Parameter(Mandatory=$true)][string]$Label,
    [string]$VfpExe='C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference='Stop'
$tool=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'resize_patient_label_tm_u220.prg')).Path
$labelPath=(Resolve-Path -LiteralPath $Label).Path
$run=Join-Path $env:TEMP ('resize_label_'+[guid]::NewGuid().ToString('N')+'.prg')
$fpw=[IO.Path]::ChangeExtension($run,'.fpw')
$code="DO `"$tool`" WITH `"$labelPath`"`r`nQUIT`r`n"
[IO.File]::WriteAllText($run,$code,[Text.Encoding]::Default)
[IO.File]::WriteAllText($fpw,"SCREEN=OFF`r`nRESOURCE=OFF`r`nCOMMAND=DO `"$run`"`r`n",[Text.Encoding]::Default)
try {
    $p=Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$fpw+'"')) -WindowStyle Hidden -PassThru
    if(-not $p.WaitForExit(60000)){throw 'Patient-label resize timed out.'}
    if($p.ExitCode -ne 0){throw "Visual FoxPro exited with code $($p.ExitCode)."}
} finally {
    Remove-Item -LiteralPath $run,$fpw -Force -ErrorAction SilentlyContinue
}
