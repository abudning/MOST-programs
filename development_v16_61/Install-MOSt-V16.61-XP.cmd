@echo off
setlocal EnableExtensions DisableDelayedExpansion
title MOSt V16.61 Windows XP Workstation Upgrade
echo MOSt V16.61 - version 1.7.662 - XP TEST CHECKPOINT
echo Close MOSt. This upgrades the existing local workstation executable only.
echo.
ver | find "5.1" >nul
if errorlevel 1 goto wrongos
wmic os get ProductType /value 2>nul | find "=1" >nul
if errorlevel 1 goto wrongos
net session >nul 2>&1
if errorlevel 1 goto admin
tasklist /FI "IMAGENAME eq MOST.exe" 2>nul | find /I "MOST.exe" >nul
if not errorlevel 1 goto running
set "TARGET=%ProgramFiles%\MOSt"
if not exist "%TARGET%\MOST.exe" goto missing
if not exist "%~dp0MOST.exe" goto missing
:choosebackup
set "BACKUP=%TARGET%\Upgrade_Backup_V16_61_%RANDOM%_%RANDOM%"
if exist "%BACKUP%" goto choosebackup
mkdir "%BACKUP%"
if errorlevel 1 goto failed
copy /B /Y "%TARGET%\MOST.exe" "%BACKUP%\MOST.exe" >nul
if errorlevel 1 goto failed
fc /B "%TARGET%\MOST.exe" "%BACKUP%\MOST.exe" >nul
if errorlevel 1 goto failed
copy /B /Y "%~dp0MOST.exe" "%TARGET%\MOST.exe" >nul
if errorlevel 1 goto restore
fc /B "%~dp0MOST.exe" "%TARGET%\MOST.exe" >nul
if errorlevel 1 goto restore
echo.
echo SUCCESS: V16.61 / 1.7.662 installed.
echo Previous executable saved in "%BACKUP%".
echo Database files and workstation configuration were not changed.
echo Follow README_V16.61.txt before approving this test build for live use.
pause
exit /b 0
:restore
copy /B /Y "%BACKUP%\MOST.exe" "%TARGET%\MOST.exe" >nul
if errorlevel 1 goto restorefailed
fc /B "%BACKUP%\MOST.exe" "%TARGET%\MOST.exe" >nul
if errorlevel 1 goto restorefailed
echo ERROR: Upgrade failed. The previous executable was restored.
pause
exit /b 6
:restorefailed
echo ERROR: Upgrade failed and automatic restore failed.
echo Close MOSt and copy "%BACKUP%\MOST.exe" to "%TARGET%\MOST.exe".
pause
exit /b 8
:wrongos
echo ERROR: Windows XP workstation required. OS verification failed or unsupported OS.
pause
exit /b 2
:admin
echo ERROR: Sign in as a local Administrator and run again.
pause
exit /b 7
:running
echo ERROR: Close MOSt before installing.
pause
exit /b 3
:missing
echo ERROR: Existing installation or package executable missing.
echo Expected installation: "%TARGET%\MOST.exe".
pause
exit /b 4
:failed
echo ERROR: Could not create and verify the backup. Upgrade stopped.
pause
exit /b 6

