param(
    [Parameter(Mandatory=$true)][string]$DailyScx,
    [Parameter(Mandatory=$true)][string]$CheckinScx,
    [string]$VfpExe='C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference='Stop'
$tool=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'patch_report_performance_v16_66_9.prg')).Path
$daily=(Resolve-Path -LiteralPath $DailyScx).Path
$checkin=(Resolve-Path -LiteralPath $CheckinScx).Path
$run=Join-Path $env:TEMP ('patch_reports_'+[guid]::NewGuid().ToString('N')+'.prg')
$fpw=[IO.Path]::ChangeExtension($run,'.fpw')
$errorLog=[IO.Path]::ChangeExtension($run,'.log')
$code="ON ERROR STRTOFILE(TRANSFORM(ERROR())+' '+MESSAGE()+' line '+TRANSFORM(LINENO()),`"$errorLog`",0)`r`nDO `"$tool`" WITH `"$daily`",`"$checkin`"`r`nQUIT`r`n"
[IO.File]::WriteAllText($run,$code,[Text.Encoding]::Default)
[IO.File]::WriteAllText($fpw,"SCREEN=OFF`r`nRESOURCE=OFF`r`nCOMMAND=DO `"$run`"`r`n",[Text.Encoding]::Default)
try {
    $p=Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$fpw+'"')) -WindowStyle Hidden -PassThru
    if(-not $p.WaitForExit(60000)){
        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        $detail=if(Test-Path -LiteralPath $errorLog){Get-Content -LiteralPath $errorLog -Raw}else{'No VFP error log was created.'}
        throw "Report patch timed out. $detail"
    }
    if(Test-Path -LiteralPath $errorLog){throw (Get-Content -LiteralPath $errorLog -Raw)}
} finally {
    Remove-Item -LiteralPath $run,$fpw,$errorLog -Force -ErrorAction SilentlyContinue
}
