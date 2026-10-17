param(
    [Parameter(Mandatory=$true)][string]$Scx,
    [Parameter(Mandatory=$true)][string]$Output,
    [string]$VfpExe='C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference='Stop'
$tool=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'export_scx_methods.prg')).Path
$run=Join-Path $env:TEMP ('export_scx_'+[guid]::NewGuid().ToString('N')+'.prg')
$fpw=[IO.Path]::ChangeExtension($run,'.fpw')
$code="DO `"$tool`" WITH `"$Scx`",`"$Output`"`r`nQUIT`r`n"
[IO.File]::WriteAllText($run,$code,[Text.Encoding]::Default)
[IO.File]::WriteAllText($fpw,"SCREEN=OFF`r`nRESOURCE=OFF`r`nCOMMAND=DO `"$run`"`r`n",[Text.Encoding]::Default)
try {
    $p=Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$fpw+'"')) -WindowStyle Hidden -PassThru
    if(-not $p.WaitForExit(60000)){throw 'SCX method export timed out.'}
    if(-not (Test-Path -LiteralPath $Output)){throw 'SCX method export did not create output.'}
} finally {
    Remove-Item -LiteralPath $run,$fpw -Force -ErrorAction SilentlyContinue
}
