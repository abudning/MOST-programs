@echo off
setlocal EnableExtensions DisableDelayedExpansion
title MOSt V16.67.1 - Windows XP workstation test upgrade
echo MOSt V16.67.1 / 1.7.696 - WORKSTATION TEST
echo Close MOSt on this workstation before continuing.
echo DO NOT run this installer on the server.
ver | find "5.1" >nul
if errorlevel 1 goto wrongos
wmic os get ProductType /value 2>nul | find "=1" >nul
if errorlevel 1 goto wrongos
net session >nul 2>&1
if errorlevel 1 goto admin
tasklist /FI "IMAGENAME eq MOST.exe" 2>nul | find /I "MOST.exe" >nul
if not errorlevel 1 goto running
set "TARGET=%ProgramFiles%\MOSt"
if not "%~1"=="" set "TARGET=%~f1"
if not exist "%TARGET%\MOST.exe" goto missing
for %%F in (MOST.exe MOSt.chm modify_claims.scx modify_claims.sct invoice.scx invoice.sct vfp9r.dll VFP9RENU.DLL msvcr71.dll ReportBuilder.app ReportOutput.app ReportPreview.app) do if not exist "%~dp0%%F" goto missing
for %%F in (patients.lbx patients.lbt) do if not exist "%~dp0labels\%%F" goto missing
echo Installation folder: "%TARGET%"
echo No database, patient, parameter, claims, EDT, or scheduler data is included.
echo The server executable will not be changed.
pause
:choosebackup
set "BACKUP=%TARGET%\Upgrade_Backup_V16_67_1_%RANDOM%_%RANDOM%"
if exist "%BACKUP%" goto choosebackup
mkdir "%BACKUP%"
if errorlevel 1 goto failed
mkdir "%BACKUP%\labels"
if errorlevel 1 goto failed
for %%F in (MOST.exe MOSt.chm modify_claims.scx modify_claims.sct invoice.scx invoice.sct vfp9r.dll VFP9RENU.DLL msvcr71.dll ReportBuilder.app ReportOutput.app ReportPreview.app) do (
 if exist "%TARGET%\%%F" (
  copy /B /Y "%TARGET%\%%F" "%BACKUP%\%%F" >nul
  if errorlevel 1 goto failed
  fc /B "%TARGET%\%%F" "%BACKUP%\%%F" >nul
  if errorlevel 1 goto failed
 )
)
if not exist "%TARGET%\labels" mkdir "%TARGET%\labels"
if errorlevel 1 goto failed
for %%F in (patients.lbx patients.lbt) do (
 if exist "%TARGET%\labels\%%F" (
  copy /B /Y "%TARGET%\labels\%%F" "%BACKUP%\labels\%%F" >nul
  if errorlevel 1 goto failed
  fc /B "%TARGET%\labels\%%F" "%BACKUP%\labels\%%F" >nul
  if errorlevel 1 goto failed
 )
)
for %%F in (MOST.exe MOSt.chm modify_claims.scx modify_claims.sct invoice.scx invoice.sct vfp9r.dll VFP9RENU.DLL msvcr71.dll ReportBuilder.app ReportOutput.app ReportPreview.app) do (
 copy /B /Y "%~dp0%%F" "%TARGET%\%%F" >nul
 if errorlevel 1 goto restore
 fc /B "%~dp0%%F" "%TARGET%\%%F" >nul
 if errorlevel 1 goto restore
)
for %%F in (patients.lbx patients.lbt) do (
 copy /B /Y "%~dp0labels\%%F" "%TARGET%\labels\%%F" >nul
 if errorlevel 1 goto restore
 fc /B "%~dp0labels\%%F" "%TARGET%\labels\%%F" >nul
 if errorlevel 1 goto restore
)
echo SUCCESS: V16.67.1 / 1.7.696 installed on this workstation.
echo Previous workstation files are in "%BACKUP%".
echo Follow TEST_PLAN.txt before installing on another workstation.
pause
exit /b 0
:restore
for %%F in (MOST.exe MOSt.chm modify_claims.scx modify_claims.sct invoice.scx invoice.sct vfp9r.dll VFP9RENU.DLL msvcr71.dll ReportBuilder.app ReportOutput.app ReportPreview.app) do if exist "%BACKUP%\%%F" copy /B /Y "%BACKUP%\%%F" "%TARGET%\%%F" >nul
for %%F in (patients.lbx patients.lbt) do if exist "%BACKUP%\labels\%%F" copy /B /Y "%BACKUP%\labels\%%F" "%TARGET%\labels\%%F" >nul
echo ERROR: Upgrade failed. Backed-up workstation files were restored.
echo Verify the installation before running MOSt.
pause
exit /b 6
:wrongos
echo ERROR: This installer is for a Windows XP workstation, not the server.
pause
exit /b 2
:admin
echo ERROR: Run this installer as a local Administrator.
pause
exit /b 7
:running
echo ERROR: Close MOSt before installing.
pause
exit /b 3
:missing
echo ERROR: Existing installation or package files are missing.
echo Expected installation: "%TARGET%\MOST.exe".
pause
exit /b 4
:failed
echo ERROR: The verified backup could not be created. Nothing was installed.
pause
exit /b 6
