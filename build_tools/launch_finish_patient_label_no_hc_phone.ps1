param(
    [Parameter(Mandatory=$true)][string]$Label,
    [string]$VfpExe='C:\Program Files (x86)\Microsoft Visual FoxPro 9\vfp9.exe'
)
$ErrorActionPreference='Stop'
$tool=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'finish_patient_label_no_hc_phone.prg')).Path
$expression=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'patient_label_referrer_expression.txt')).Path
$labelPath=(Resolve-Path -LiteralPath $Label).Path
$run=Join-Path $env:TEMP ('finish_label_'+[guid]::NewGuid().ToString('N')+'.prg')
$fpw=[IO.Path]::ChangeExtension($run,'.fpw')
$errorLog=[IO.Path]::ChangeExtension($run,'.log')
$code="ON ERROR STRTOFILE(TRANSFORM(ERROR())+' '+MESSAGE()+' line '+TRANSFORM(LINENO()),`"$errorLog`",0)`r`nDO `"$tool`" WITH `"$labelPath`",`"$expression`"`r`nIF FILE(`"$errorLog`")`r`n  QUIT`r`nENDIF`r`nQUIT`r`n"
[IO.File]::WriteAllText($run,$code,[Text.Encoding]::Default)
[IO.File]::WriteAllText($fpw,"SCREEN=OFF`r`nRESOURCE=OFF`r`nCOMMAND=DO `"$run`"`r`n",[Text.Encoding]::Default)
try {
    $p=Start-Process -FilePath $VfpExe -ArgumentList @('-t',('-c"'+$fpw+'"')) -WindowStyle Hidden -PassThru
    if(-not $p.WaitForExit(60000)){
        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        $detail=if(Test-Path -LiteralPath $errorLog){Get-Content -LiteralPath $errorLog -Raw}else{'No VFP error log was created.'}
        throw "Patient-label edit timed out. $detail"
    }
    if($p.ExitCode -ne 0){throw "Visual FoxPro exited with code $($p.ExitCode)."}
} finally {
    Remove-Item -LiteralPath $run,$fpw,$errorLog -Force -ErrorAction SilentlyContinue
}
