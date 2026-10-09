@echo off
setlocal EnableExtensions DisableDelayedExpansion
title MOSt V16.66.4 - Windows XP test workstation upgrade
echo MOSt V16.66.4 / 1.7.690 - TEST BUILD
echo Close MOSt before installing. Existing workstation installation required.
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
for %%F in (MOST.exe modify_claims.scx modify_claims.sct invoice.scx invoice.sct vfp9r.dll VFP9RENU.DLL msvcr71.dll ReportBuilder.app ReportOutput.app ReportPreview.app) do if not exist "%~dp0%%F" goto missing
echo Installation folder: "%TARGET%"
echo No database files are included in this upgrade.
echo Use a test workstation configured for test data.
pause
:choosebackup
set "BACKUP=%TARGET%\Upgrade_Backup_V16_66_4_%RANDOM%_%RANDOM%"
if exist "%BACKUP%" goto choosebackup
mkdir "%BACKUP%"
if errorlevel 1 goto failed
for %%F in (MOST.exe modify_claims.scx modify_claims.sct invoice.scx invoice.sct vfp9r.dll VFP9RENU.DLL msvcr71.dll ReportBuilder.app ReportOutput.app ReportPreview.app) do (
 if exist "%TARGET%\%%F" (
  copy /B /Y "%TARGET%\%%F" "%BACKUP%\%%F" >nul
  if errorlevel 1 goto failed
  fc /B "%TARGET%\%%F" "%BACKUP%\%%F" >nul
  if errorlevel 1 goto failed
 )
)
for %%F in (MOST.exe modify_claims.scx modify_claims.sct invoice.scx invoice.sct vfp9r.dll VFP9RENU.DLL msvcr71.dll ReportBuilder.app ReportOutput.app ReportPreview.app) do (
 copy /B /Y "%~dp0%%F" "%TARGET%\%%F" >nul
 if errorlevel 1 goto restore
 fc /B "%~dp0%%F" "%TARGET%\%%F" >nul
 if errorlevel 1 goto restore
)
echo SUCCESS: V16.66.4 / 1.7.690 installed.
echo Previous files saved in "%BACKUP%".
echo Start MOSt and follow README_V16.66.4_XP_TEST.txt.
pause
exit /b 0
:restore
for %%F in (MOST.exe modify_claims.scx modify_claims.sct invoice.scx invoice.sct vfp9r.dll VFP9RENU.DLL msvcr71.dll ReportBuilder.app ReportOutput.app ReportPreview.app) do (
 if exist "%BACKUP%\%%F" (
  copy /B /Y "%BACKUP%\%%F" "%TARGET%\%%F" >nul
  if errorlevel 1 goto restorefailed
  fc /B "%BACKUP%\%%F" "%TARGET%\%%F" >nul
  if errorlevel 1 goto restorefailed
 )
)
echo ERROR: Upgrade failed. Original files were restored.
echo Newly supplied support files may remain in the installation folder.
pause
exit /b 6
:restorefailed
echo ERROR: Automatic restore failed. Close MOSt and restore files from "%BACKUP%".
pause
exit /b 8
:wrongos
echo ERROR: This installer requires a Windows XP workstation.
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
echo ERROR: Existing installation or package files missing.
echo Expected installation: "%TARGET%\MOST.exe".
pause
exit /b 4
:failed
echo ERROR: Could not create and verify the backup. Installation stopped.
pause
exit /b 6
