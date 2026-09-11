# MOSt V16.15 workstation test installers

Release label: **V16.15**  
Executable version: **1.7.612**

## Corrections

- Claims opens its fee cursor from the configured shared MOSt database.
- `CONFIG.FPW` disables the unnecessary Visual FoxPro resource file.
- Installed shortcuts explicitly use that configuration, allowing Windows 11
  to run MOSt normally and retain the user's mapped `K:` drive.

## Packages

- `MOSt_Workstation_Upgrade_V16.15_Windows_10_11.zip`
- `MOSt_Workstation_Upgrade_V16.15_Windows_XP.zip`

These are upgrade-only test packages for existing MOSt workstations. Extract
the entire appropriate ZIP, close MOSt, and run
`Install-MOSt-V16.15-Workstation.cmd`. The installer backs up the current
executable before replacing it. It copies no DBF, DBC, DCT, DCX, CDX, or FPT
clinical database files.

Do not run MOSt as administrator after installation. The XP package is ZIP-only
because the previous self-extracting launcher is not compatible with XP.

Test A233A on a new claim and confirm the amount matches the current shared fee
table before submitting production claims.
